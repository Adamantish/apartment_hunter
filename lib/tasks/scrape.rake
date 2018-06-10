require 'rails'
require "#{Rails.root}/app/scrapers/apartment_scraper.rb"

task :scrape do
  Rails.application.initialize!
  
  4.times do
    # ApartmentScraper.go(tell: true, noisy: true)
    ApartmentScraper.go
    sleep 60 * 2
  end
end