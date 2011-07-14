class BadgePeriodCount < ActiveHash::Base
  fields :id, :name
  
  create :id => 1, :name => 'streak' 
  create :id => 2, :name => 'cycle'
end