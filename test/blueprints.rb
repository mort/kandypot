require 'machinist/active_record'

App.blueprint do
  name { "app#{sn}" }
  nicename { "app#{sn}" }
end

Activity.blueprint do
  app
  uuid
  verb { "verb{sn}" }
  published { Time.now }
  
end