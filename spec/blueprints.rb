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
Sham.credentials_app_token { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }
Sham.credentials_signature { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }
Sham.content_token { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }
Sham.content_owner_member_token { Digest::SHA1.hexdigest(Faker::Lorem.sentence) }


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

Activity.blueprint do
  credentials_app_token 
  credentials_signature
  member_token
  content_token
  activity_type { 'content_creation' }
  content_type { 'foo' }
  content_source { 'ugc' }
  ip { '127.0.0.1' }
  activity_at { Time.now }
end

Activity.blueprint(:reaction) do
  credentials_app_token
  credentials_signature
  member_token
  content_token
  content_owner_member_token
  activity_type { 'reaction_comment' }
  content_type { 'foo' }
  content_source { 'ugc' }
  ip { '127.0.0.1' }
  activity_at { Time.now }
end