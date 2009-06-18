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

class App < ActiveRecord::Base
  validates_presence_of :name, :nicename, :app_key, :app_token
  validates_uniqueness_of :name, :nicename, :app_key, :app_token
  
  before_validation :generate_credentials
  
  private
  
  def generate_credentials
    
    size = Settings.apps.credentials.key_length
    
    [:app_key=, :app_token=].each do |a|
      self.send(a,KeyGenerator.generate(size))
    end
  end
  
  
end
