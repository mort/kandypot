require 'rubygems'
require 'spork'
require 'digest/md5'

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require 'factory_girl'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}



FactoryGirl.find_definitions 


Spec::Runner.configure do |config|  
  config.include Factory::Syntax::Methods
  config.mock_with :rspec
  
  config.use_transactional_fixtures = false

  config.before :each do
    clean_db
  end
end
  
  
def clean_db
    (ActiveRecord::Base.connection.tables - %w{schema_migrations}).each do |table_name|
      ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{table_name};"
    end
end
  

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









