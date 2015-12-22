require 'simplecov'
require 'active_merchant_pay2go'
require 'test/unit'

begin
  require 'rubygems'
  require 'bundler'
  require 'json'
  Bundler.setup
rescue LoadError => e
  puts "Error loading bundler (#{e.message}): \"gem install bundler\" for bundler support."
end

SimpleCov.start
ActiveMerchant::Billing::Base.mode = :test