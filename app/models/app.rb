# == Schema Information
# Schema version: 20090618172719
#
# Table name: apps
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  nicename      :string(255)
#  url           :string(255)
#  app_key       :string(255)
#  app_token     :string(255)
#  ip            :string(15)
#  description   :text
#  members_count :integer(4)      default(0), not null
#  kandies_count :integer(4)      default(0), not null
#  status        :integer(2)      default(1), not null
#  created_at    :datetime
#  updated_at    :datetime
#

require 'hmac-sha1'

class App < ActiveRecord::Base
  
  SETTINGS_BASE_PATH = Rails.root.join('config','app_settings')
  
  validates_presence_of :name, :nicename, :app_key, :app_token
  validates_uniqueness_of :name, :nicename, :app_key, :app_token
  
  before_validation :generate_credentials
  
  has_many :members
  has_many :notifications, :order => 'created_at DESC'
  
  def self.default_settings_path
    [App::SETTINGS_BASE_PATH, "default.yml"].join('/')
  end
  
  def self.authenticate(app_token, data, signature)
    app = App.find_by_app_token(app_token)
    if app
      (OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, app.app_key, data)  == signature)
    else
      return false
    end
  end
  
  def self.pack_up_params_for_signature(params) 
    return false unless params.is_a?(Hash)
    return Digest::SHA1.hexdigest(params.to_s)   
  end
  
  
  def has_settings?
    return true if File.exists?(self.settings_filepath)
  end
  
  def settings_filepath
    [App::SETTINGS_BASE_PATH, "#{self.nicename}.yml"].join('/')
  end
  
  def settings
    @settings ||= (self.has_settings? ? Settings.new(settings_filepath) : Settings.new(App.default_settings_path))
  end
  
  
  private
  
  def generate_credentials
    
    size = Settings.apps.credentials.key_length
    
    [:app_key=, :app_token=].each do |a|
      self.send(a,KeyGenerator.generate(size))
    end
  end
  
  
  
  
end
