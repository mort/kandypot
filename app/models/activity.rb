require 'uuid'

class Activity < ActiveRecord::Base
  require 'hammurabi'
  include Kandypot::Hammurabi
  
  API_PARAMS = [:actor_token, :verb, :published, :object_token, :object_url, :object_author_token, :mood, :intensity]
  
  MOOD_TYPES = ['positive', 'negative', 'neutral']
  
  belongs_to :app
  
  # common
  validates_presence_of  :actor_token, :verb, :category, :ip, :published, :uuid
  
  # We need either object_token (when the object is a Person) or an object_url (when the object is something else)  
  validates_presence_of :object_token, :if => Proc.new {|act| act.person_object? }  
  validates_presence_of :object_url, :if =>   Proc.new {|act| act.content_object? }

  # If the object is not a person, we need info about its author
  validates_presence_of :object_author_token, :if =>  Proc.new {|act| act.content_object? }
  
  validates_inclusion_of :mood, :in => MOOD_TYPES, :allow_nil? => true
    
  before_validation :set_defaults
  
  after_create do |activity|
    activity.send_later(:judge)
  end
  
  def validate
    validate_reward_setting(verb, object_type)
  end
  
  def set_defaults
    self.uuid     = set_uuid
    self.category = set_category
  end
  
  def reward
    begin
      app.settings.rewards.send(verb).send(object_type)
    rescue NoMethodError
      app.settings.rewards.send(verb).send(:default)
    end
  end
  
  def activityId
    'wadus'
  end
  
  def actorId
    'wadus'
  end
  
  def object_authorId
    'wadus'
  end
  
  def objectId
    'wadus'
  end
    
  private
  
  def set_category
    if no_object?
      # Sign-ups, etc.
      'singular'
    elsif object_is?(:person)
      # DMs, new friendship, etc.
      'interaction'
    elsif has_verb?(:post)
      # Content upload
      'creation'  
    else
      # Comments, favorites, sharing, etc.
      'reaction'  
    end
  end
  
  def set_uuid
    UUID.new.generate
  end
  
  def no_object?
    (object_type.blank? && object_url.blank? && object_token.blank?)
  end
  
  def object_is?(object_sym)
    (object_type.to_sym == object_sym)
  end
  
  def content_object?
    !object_is?(:person)
  end

  def person_object?
    object_is?(:person)
  end

  def has_verb?(verb_sym)
    self.verb.to_sym == verb_sym
  end

  def validate_reward_setting(verb, object_type = nil)
    object_type.present? ? validate_verb_object_type(verb, object_type) :  validate_verb(verb)
  end

  def validate_verb_object_type(verb, object_type)
    begin
      app.settings.rewards.send(verb).send(object_type)
    rescue NoMethodError
      validate_verb(verb)
    end
  end
  
  def validate_verb(verb)
    begin
      app.settings.rewards.send(verb).send(:default)
    rescue NoMethodError
      errors.add("Verb #{verb} is not registered with this app")
    end
  end

  

end

# == Schema Information
#
# Table name: activities
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
#  updated_at          :datetime
#

