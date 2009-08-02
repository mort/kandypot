# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/autorun'
require 'spec/rails'
require File.expand_path(File.dirname(__FILE__) + "/blueprints")
require File.expand_path(File.dirname(__FILE__) + "/be_valid_feed")
require 'feed_validator/assertions'
require 'logger'


def sign_request(app, options = {})
  logger = Logger.new(File.expand_path(File.dirname(__FILE__) + "/../log/test.log"))
  logger.info("options #{options.inspect}")
  params = options.stringify_keys.merge({'date_scope' => Time.now.midnight.utc.iso8601})
  par_str = params.sort.map{|j| j.join('=')}.join('&')
  str = Digest::SHA1.hexdigest(par_str)
  
  signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, app.app_key, str)
  logger.info("1 - #{params.inspect} par_str: #{par_str} str: #{str} signature: #{signature}")
  
  return {:signature => signature}
end


Spec::Runner.configure do |config|
  config.mock_with :rr
  config.before(:each) { Sham.reset }
  
  config.before(:each) do
    full_example_description = "Starting #{self.class.description} #{@method_name}"
    RAILS_DEFAULT_LOGGER.info("\n\n#{full_example_description}\n#{'-' * (full_example_description.length)}")
  end
  
  
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


require 'digest/md5'
 
class ActionController::TestCase
  def authenticate_with_http_digest(user = 'admin', password = 'admin', realm = 'Application')
    unless ActionController::Base < ActionController::ProcessWithTest
      ActionController::Base.class_eval { include ActionController::ProcessWithTest }
    end
 
    @controller.instance_eval %Q(
      alias real_process_with_test process_with_test
 
      def process_with_test(request, response)
        credentials = {
          :uri => request.env['REQUEST_URI'],
          :realm => "#{realm}",
          :username => "#{user}",
          :nonce => ActionController::HttpAuthentication::Digest.nonce,
          :opaque => ActionController::HttpAuthentication::Digest.opaque,
        }
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Digest.encode_credentials(
          request.request_method, credentials, "#{password}", false
        )
        real_process_with_test(request, response)
      end
    )
  end
end
