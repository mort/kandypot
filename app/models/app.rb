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
  
  validates_presence_of :name, :nicename, :app_key, :app_token, :url
  validates_uniqueness_of :name, :nicename, :app_key, :app_token, :url
  
  validates_subdomain_format_of :nicename
  validates_subdomain_not_reserved :nicename
  
  before_validation :generate_credentials
  
  has_many :members
  has_many :notifications, :order => 'created_at DESC'
  has_many :activities
  has_many :badges
  
  def to_param
     nicename
   end
  
  def self.default_settings_path
    File.join(SETTINGS_BASE_PATH, "default.yml")
  end
  
  def authenticate(data, signature)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, self.app_key, data)  == signature
  end
  
  def self.pack_up_params_for_signature(params) 
    return false unless params.is_a?(Hash)
    return Digest::SHA1.hexdigest(params.to_s)   
  end
  
  
  def has_settings?
    File.exists?(self.settings_filepath)
  end
  
  def settings_filepath
    [App::SETTINGS_BASE_PATH, "#{self.nicename}.yml"].join('/')
  end
  
  def settings
    path = self.has_settings? ? settings_filepath : App.default_settings_path
    @settings ||= Settings.new(path)
  end
  
  def update_members_kandy_cache
    members.all.each do |member|
      member.update_kandy_cache
    end
    self.update_attribute(:updated_at, Time.now)
  end
  
  def api_auth_realm
    "#{nicename}@#{Settings.auth.realm}"
  end
    
  private
  
  def generate_credentials
    
    size = Settings.apps.credentials.key_length
    
    [:app_key=, :app_token=].each do |a|
      self.send(a,KeyGenerator.generate(size))
    end
  end
  
  
  
  
end
