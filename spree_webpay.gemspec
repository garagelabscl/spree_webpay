# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_webpay/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_webpay'
  s.version     = SpreeWebpay.version
  s.summary     = 'Webpay Chilean Payment Gateway for Spree Commerce'
  s.description = 'Webpay Chilean Payment Gateway for Spree Commerce'
  s.required_ruby_version = '>= 2.2.7'

  s.author    = 'Daniel Vargas'
  s.email     = 'daniel@garagelabs.cl'
  s.homepage  = 'https://github.com/garagelabscl/spree_webpay'
  s.license = 'BSD-3-Clause'

  # s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 4.0', '<= 4.8.0.beta'
  s.add_dependency 'spree_core', spree_version
  s.add_dependency 'spree_backend', spree_version
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'pg', '~> 0.18'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'transbank-sdk'
end
