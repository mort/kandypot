# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/autorun'
require 'spec/rails'
require File.expand_path(File.dirname(__FILE__) + "/blueprints")
require File.expand_path(File.dirname(__FILE__) + "/be_valid_feed")

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.before(:each) { Sham.reset }
  
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  #config.use_transactional_fixtures = true
  #config.use_instantiated_fixtures  = false
  #config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end


def sign_n_make(a, app)  
  params = {}
  params["member_token"]   = a[:member_token]
  params["activity_type"]  = a[:activity_type]
  params["activity_at"]    = a[:activity_at]

  s = Digest::SHA1.hexdigest(params.to_s)   

  a[:signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, app.app_key, s)
  mock(App).pack_up_params_for_signature(params){ s }
  mock(App).authenticate(a[:app_token], s, a[:signature]){true}
  return Activity.make(a)
end