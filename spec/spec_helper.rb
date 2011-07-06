require 'rubygems'
#require 'spork'

#Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  require 'spec/autorun'
  require 'spec/rails'
  require 'factory_girl'
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

#end

#Spork.each_run do
   Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}
#end







