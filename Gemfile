source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '2.3.11'
gem 'mysql', '2.8.1'

gem "settingslogic", "2.0.6"
gem 'wvanbergen-http_status_exceptions', '0.1.3', :require => 'http_status_exceptions'
gem 'javan-whenever', '0.3.0'
gem 'daemons', '1.0.10'
gem "subdomain_routes", '0.3.1', :require => "subdomain_routes"
gem 'hoptoad_notifier', '2.1.3'
gem 'will_paginate', '~> 2.3.11'
gem 'ruby-hmac', '0.4.0'
gem 'uuid', '2.3.1'
gem 'active_hash', "~> 0.9.5", :require => 'active_hash'
gem 'rabl'
gem 'test-unit', '1.2.3'

group :development do
	gem 'annotate', '2.4.0'
end


group :development, :test do
  #gem 'rspec', "1.3.3",  :require => false
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard' 
  gem 'growl' 
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'spork', '0.8.5'
  gem 'factory_girl', "~> 2.0.0.rc1"
  gem 'forgery'
  gem 'guard-bundler'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'delorean', "~> 1.1.0"
  gem "rack-test", :require => "rack/test"
end
