require 'machinist/active_record'
require 'sham'
require 'faker'
require 'digest/sha1'

Sham.name  { Faker::Name.name }
Sham.email { Faker::Internet.email }
Sham.title { Faker::Lorem.sentence }
Sham.body  { Faker::Lorem.paragraph }
Sham.nicename { Faker::Lorem.words(1) }
Sham.member_token { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }

App.blueprint do
  name
  nicename 
end

Member.blueprint do
  app
  member_token 
end

Kandy.blueprint do
end

KandyOwnership.blueprint do 
  member
  kandy 
  status { "1" }
end

