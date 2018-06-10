class ApartmentScraper
  class << self
    def go(noisy: false, tell: false)
      @noisy = noisy
      @tell = tell
      @voice = 'Daniel'

      @domain = 'https://www.wg-gesucht.de'
      url = "#{@domain}/wg-zimmer-in-Berlin.8.0.1.0.html?offer_filter=1&noDeact=1&city_id=8&category=0&rent_type=0&sMin=12&rMax=500&dFr=1529964000&dTo=1532383200&ot%5B132%5D=132&ot%5B85079%5D=85079&ot%5B151%5D=151&ot%5B163%5D=163&ot%5B165%5D=165&ot%5B178%5D=178&wgSea=2&wgAge=33&sin=1"
      doc = Nokogiri::HTML(HTTParty.get(url))

      panels = doc.css('#main_column > .list-details-ad-border:not(.panel-hidden) .list-details-panel-inner')
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
      
      candidates.each do |panel|
        main_a = panel.css('a.detailansicht')
        ad_link = main_a.xpath("@href").first.to_s
        ad_title = main_a.children.first.inner_text.strip
        maybe_inform(ad_title, ad_link)
      end
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
        puts ad_link
        MainMailer.new_scam(title: title, link: ad_link).deliver_now
        tell(ad_link) if @tell
        apt.update!(ad_title: title)
      end
    end
  end
end