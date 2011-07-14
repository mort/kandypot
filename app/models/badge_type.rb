class BadgeType < ActiveHash::Base
  fields :id, :name
  
  self.data = [
    {:id => 1, :name => "newbish"}   ,
    {:id => 2, :name => "diversity"} ,
    {:id => 3, :name => "streak"}    ,
    {:id => 4, :name => "cycle"}     
    ]

  # :id => 5, :name => "ranking"
  # :id => 6, :name => "codependency"
end