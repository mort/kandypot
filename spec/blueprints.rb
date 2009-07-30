require 'machinist/active_record'
require 'sham'
require 'faker'
require 'digest/sha1'

Sham.name  { Faker::Name.name }
Sham.email { Faker::Internet.email }
Sham.title { Faker::Lorem.sentence }
Sham.body  { Faker::Lorem.paragraph }
Sham.nicename { Faker::Lorem.words(1)[0] }
Sham.member_token { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }
Sham.app_token { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }
Sham.signature { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }
Sham.content_token { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }
Sham.member_b_token { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }
Sham.category { Faker::Lorem.words(1) }


App.blueprint do
  name
  nicename 
end

Member.blueprint do
  app
  member_token 
  kandies_count { 0 }
end

Kandy.blueprint do
end

KandyOwnership.blueprint do 
  member
  kandy 
  status { "1" }
end

Activity.blueprint do
  app
  member_token
  content_token
  activity_type { 'creation' }
  content_type { 'foo' }
  content_source { 'ugc' }
  ip { '127.0.0.1' }
  activity_at { Time.now }
end

Activity.blueprint(:reaction) do
  app
  member_token
  member_b_token
  content_token
  activity_type { 'reaction' }
  category { 'comment' }
  content_type { 'foo' }
  content_source { 'ugc' }
  ip { '127.0.0.1' }
  activity_at { Time.now }
end

Activity.blueprint(:relationship) do
  app
  member_token
  member_b_token
  content_token
  activity_type { 'relationship' }
  category { 'dm' }
  ip { '127.0.0.1' }
  activity_at { Time.now }
end


Notification.blueprint do
  app
  title 
  body 
  category 
end