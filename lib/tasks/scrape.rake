require 'rails'
require "#{Rails.root}/app/scrapers/apartment_scraper.rb"

task :scrape do
  Rails.application.initialize!
  
  ApartmentScraper.go
  2.times do
    sleep 60 * 3
    ApartmentScraper.go
  end
end