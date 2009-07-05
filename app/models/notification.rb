# == Schema Information
# Schema version: 20090702181526
#
# Table name: notifications
#
#  id         :integer(4)      not null, primary key
#  app_id     :integer(4)
#  title      :string(255)     default(""), not null
#  body       :text            default(""), not null
#  category   :string(255)     default(""), not null
#  created_at :datetime
#  updated_at :datetime
#

class Notification < ActiveRecord::Base
  belongs_to :app
  
  validates_presence_of :title, :body, :category
end
