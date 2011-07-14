require 'digest/md5'

FactoryGirl.define do
  
  sequence :email do |n|
    "user#{n}@peercouture.com"
  end
  
  sequence :appname do |n|
    "app#{n}"
  end
  
  factory :app do
    name { Factory.next(:appname) }
    nicename {name}
    url { "http://#{name}.com" }
  end
  
  factory :member do 
    app
    member_token { Digest::MD5.hexdigest(Factory.next(:email))  }
  end
  
  
  factory :act, :class => Activity, :aliases => [:activity] do
    app
    actor_token { Digest::MD5.hexdigest(Factory.next(:email)) }
    verb  'signup' 
    ip '127.0.0.1' 
    published { Time.now }
    
    factory :creation_act do
      verb 'post'
      object_type 'photos'
      object_url 'http://example.com/photos /wadus'
    end
    
    factory :reaction_act do
      verb 'comment'
      target_type 'wadus'
      target_url 'http://example.com/posts/wadus'
      target_author_token { Digest::MD5.hexdigest(Factory.next(:email)) }
    end
    
    factory :interaction_act do
      verb 'friendship'
      target_type 'person'
      target_token { Digest::MD5.hexdigest(Factory.next(:email)) }
    end
    
    
  end 
  
  factory :op, :class => OperationLog do
    activity
    app { activity.app }  
    data {
      
      h = Hash.new
      h[:actor_token] = Digest::MD5.hexdigest(Factory.next(:email))
      h[:do_reward] = true
      h[:do_transfer] = false
      h[:reward_amount] = 10
      
      h
      
    }
    
  end

  
    
  factory :transfer_op, :class => OperationLog do
    activity
    app { activity.app } 
    
    data {
      h = Hash.new
      h[:actor_token] = Digest::MD5.hexdigest(Factory.next(:email))
      h[:transfer_recipient_token] = Digest::MD5.hexdigest(Factory.next(:email))
      h[:do_reward] = true
      h[:do_transfer] = true
      h[:reward_amount] = 10
      h[:transfer_amount] = 1
      h
    }
  end


  factory :newbish_badge, :class => Badge do
    app
    badge_type 'newbish'
    title 'Newbish badge'
    description 'Foo'
    verb 'signup'
    qtty '1'
    badge_scope 1
    predicate_types '*'
    variant 'badge'
    repeatable false
    
    factory :diversity_badge do
      badge_type 'diversity'
      title 'Diversity Badge'
      verb 'post'
      qtty '5'
      badge_scope 1
      predicate_types 'foo,bar'
    end
    
    
  end



end  
  #
  #  id                  :integer(4)      not null, primary key
  #  app_id              :integer(4)
  #  processed_at        :datetime
  #  proccessing_status  :integer(2)
  #  ip                  :string(15)      not null
  #  category            :string(25)      not null
  #  uuid                :string(36)      not null
  #  published           :datetime        not null
  #  actor_token         :string(32)      not null
  #  verb                :string(255)     not null
  #  object_type         :string(255)
  #  object_token        :string(255)
  #  object_url          :string(255)
  #  object_author_token :string(255)
  #  mood                :string(25)
  #  intensity           :integer(2)
  #  created_at          :datetime
  #  updated_at          :datetim
  

