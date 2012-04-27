class Notification < ActiveRecord::Base
  belongs_to :app
  
  validates_presence_of :title, :body, :category
end

# == Schema Information
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
# Indexes
#
#  index_notifications_on_app_id  (app_id)
#

