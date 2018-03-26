# encoding: UTF-8

$:.push File.expand_path('../lib', __FILE__)
require 'solidus_referral/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_referral'
  s.version     = SolidusReferral::VERSION
  s.summary     = 'An extension which adds referrals to Solidus'
  s.description = 'This extension adds the required methods in the Spree::User model class and provides both a promotion rule and a promotion action.'
  s.license     = 'MIT License'

  s.author    = 'Epicery'
  s.email     = 'contact@epicery.com'
  s.homepage  = 'http://wwww.epicery.com'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'solidus_core', '~> 2.4'
  s.add_dependency 'solidus_backend', '~> 2.4'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-webkit'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency "factory_bot"
  s.add_development_dependency "ffaker"
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'rubocop', '~> 0.49.0'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
