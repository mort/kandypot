class Notification < ActiveRecord::Base
  belongs_to :app
  
  validates_presence_of :title, :body, :category
end
