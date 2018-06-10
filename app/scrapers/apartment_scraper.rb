class ApartmentScraper
  class << self
    def go(noisy: false, tell: false)
      @noisy = noisy
      @tell = tell
      @voice = 'Daniel'

      @domain = 'https://www.wg-gesucht.de'
      url = "#{@domain}/wg-zimmer-in-Berlin.8.0.1.0.html?offer_filter=1&sort_column=0&noDeact=1&city_id=8&category=0&rent_type=0&sMin=19&rMax=500&dFr=1529964000&dTo=1532383200&radLat=52.5105357&radLng=13.434982699999978&radAdd=Ostbahnhof%2C+Koppenstraße%2C+Berlin%2C+Deutschland&radDis=4000&wgSea=2&wgAge=33&sin=1"
      doc = Nokogiri::HTML(HTTParty.get(url))

      panels = doc.css('#main_column > .list-details-ad-border:not(.panel-hidden) .list-details-panel-inner')
      scrape_record = Scrape.create!
      candidates = panels.select do |panel|
        begin
          possible_end_date = panel.css('b').last.inner_text
          if possible_end_date.length == 12
            end_date = possible_end_date[2..-1].to_date
            end_date >= 3.months.from_now
          else
            true
          end
        rescue StandardError => ex
          puts ex
          false
        end
      end

      scrape_record.ads = candidates.count

      @new_count = 0

      candidates.each do |panel|
        main_a = panel.css('a.detailansicht')
        ad_link = main_a.xpath("@href").first.to_s
        ad_title = main_a.children.first.inner_text.strip
        maybe_inform(ad_title, ad_link)
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

    def maybe_inform(title, link)
      ad_link = "#{@domain}/#{link}"
      apt = Apartment.find_or_initialize_by(ad_link: "#{@domain}/#{link}")

      unless apt.persisted?
        @new_count += 1
        puts ad_link
        MainMailer.new_scam(title: title, link: ad_link).deliver_now
        tell(ad_link) if @tell
        apt.update!(ad_title: title)
      end
    end
  end
end