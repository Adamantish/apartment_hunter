require 'rails'
require "#{Rails.root}/app/scrapers/apartment_scraper.rb"

task :scrape do
  Rails.application.initialize!
  
  2.times do
    ApartmentScraper.go
    sleep 60 * 3
  end
end