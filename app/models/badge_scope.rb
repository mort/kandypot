class BadgeScope < ActiveHash::Base
  fields :id, :name
  
  self.data = [
     {:id => 1, :name => 'member'},
     {:id => 2, :name => 'app'},
     {:id => 3, :name => 'global'}
  ]

end