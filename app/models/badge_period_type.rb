class BadgePeriodType < ActiveHash::Base
  fields :id, :name
  
  self.data = [ 
                {:id => 1, :name => 'year'},
                {:id => 2, :name => 'month'},
                {:id => 3, :name => 'day'},
                {:id => 4, :name => 'hour'}  
              ] 
end