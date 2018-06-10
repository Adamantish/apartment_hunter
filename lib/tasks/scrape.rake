require 'rails'
require "#{Rails.root}/app/scrapers/apartment_scraper.rb"

task :scrape do
  Rails.application.initialize!
  
  3.times do
    # ApartmentScraper.go(tell: true, noisy: true)
    ApartmentScraper.go
    sleep 60 * 3
  end
end