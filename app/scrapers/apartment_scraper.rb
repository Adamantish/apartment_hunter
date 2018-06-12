class ApartmentScraper
  FINDERS = {
    'York' =>    { date_filter: ->(end_date){ end_date ? (1.month.from_now..4.months.from_now).include?(end_date) : false }
    },
    'ME' =>      { date_filter: ->(end_date){ end_date ? end_date >= 3.months.from_now : true }
    },
    'Florian' => { date_filter: ->(end_date){ end_date ? end_date >= 12.months.from_now : true }
    },
  }.freeze

  class << self
    def go(noisy: false, tell: false)
      @@people ||= Person.all.to_a

      @noisy = noisy
      @tell = tell
      @voice = 'Daniel'
      @domain = 'https://www.wg-gesucht.de'

      @@people.each do |person|
        scrape_for(person: person)
      end
    end

    def scrape_for(person: person)
      doc = Nokogiri::HTML(HTTParty.get(person.search_url))

      panels = doc.css('#main_column > .list-details-ad-border:not(.panel-hidden) .list-details-panel-inner')
      scrape_record = Scrape.create!

      date_filter = FINDERS[person.name][:date_filter]

      if date_filter
        panels = panels.select do |panel|
          begin
            possible_end_date = panel.css('b').last.inner_text
            end_date = possible_end_date.length == 12 ? possible_end_date[2..-1].to_date : nil
            date_filter.call(end_date)
          rescue StandardError => ex
            puts ex
            false
          end
        end
      end

      scrape_record.ads = panels.count

      @new_count = 0

      panels.each do |panel|
        main_a = panel.css('a.detailansicht')
        ad_link = main_a.xpath("@href").first.to_s
        ad_title = main_a.children.first.inner_text.strip
        maybe_inform(person, ad_title, ad_link)
      end

      scrape_record.update!(new_ads: @new_count)
    end

    def tell(message, time = nil)
      puts "#{time}: #{message}"
      notify = %(osascript -e 'display notification \"#{message.gsub("'","")}\" with title \"Apartment!\"')
      `#{notify}`
      if @noisy
        `afplay /System/Library/Sounds/Blow.aiff`
        `say -v #{@voice} "Oh baby yeah! Another scam"`
      end
    end

    def maybe_inform(person, title, link)
      ad_link = "#{@domain}/#{link}"
      apt = Apartment.find_or_initialize_by(person_id: person.id, ad_link: ad_link)

      unless apt.persisted?
        @new_count += 1
        puts ad_link
        MainMailer.new_scam(person.email, { title: title, link: ad_link }).deliver_now
        tell(ad_link) if @tell
        apt.update!(ad_title: title)
      end
    end
  end
end