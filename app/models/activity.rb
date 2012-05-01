require 'uuid'
require 'hammurabi'

class Activity < ActiveRecord::Base

  attr_accessor :op_data

  API_PARAMS = [:actor_token, :verb, :published, :object_token, :object_type, :object_url, :target_token, :target_url, :target_author_token, :target_type, :mood, :intensity]

  MOOD_TYPES = [1, -1, 0]

  belongs_to :app

  before_validation :set_defaults

  ## VALIDATIONS

  # common
  validates_presence_of  :actor_token, :verb, :category, :ip, :published, :uuid
  validates_inclusion_of :mood, :in => MOOD_TYPES, :allow_nil => true

  # tokens
  validates_format_of :actor_token, :target_token, :target_author_token, :with => /^([a-f0-9]{32})$/, :allow_nil => true

  # urls
  validates_format_of :object_url, :target_url, :with => /^((http|https?):\/\/((?:[-a-z0-9]+\.)+[a-z]{2,}))/, :allow_nil => true

  # We need an object url and an object type when the verb is 'post'
  validates_presence_of :object_url, :object_type, :if => Proc.new {|act| act.verb_is?(:post) }

  # We need a target_type if the target is present and either target_token (when the target is a Person) or an target_url (when the target is something else)
  validates_presence_of :target_type, :if =>  Proc.new {|act|  act.has_target? }
  validates_presence_of :target_token, :if => Proc.new {|act|  act.person_target? }
  validates_presence_of :target_url, :if => Proc.new {|act| act.content_target? }

  # If the target is not a person, we need info about its author
  validates_presence_of :target_author_token, :if =>  Proc.new {|act| act.content_target? }

  has_one :operation_log, :dependent => :destroy

  after_create :process

  def validate
    validate_reward_setting(verb, object_type)
  end

  def set_defaults
    self.uuid     = UUID.new.generate
    self.category = guess_category
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

  def guess_category
    if (no_object? && no_target?)
      # Sign-ups, etc.
      'singular'
    elsif has_object? && verb_is?(:post)
      # Content upload
      'creation'
    elsif person_target?
      # DMs, new friendship, etc.
      'interaction'
    elsif content_target?
      # Comments, favorites, sharing, etc.
      'reaction'
    else
      raise Exceptions::Kandypot::UnknownActivityCategory, self.inspect
    end
  end

  def predicate_attr
    p = (category?(:creation) ? 'object' : 'target')
    "#{p}_type".to_sym
  end

  def predicate_type
    read_attribute(predicate_attr)
  end

  def category?(cat)
    category == cat.to_s
  end

  def no_object?
    (object_type.blank? && object_url.blank?)
  end

  def has_object?
    !no_object?
  end

  def no_target?
    (target_type.blank? && target_url.blank? && target_token.blank?)
  end

  def has_target?
    !no_target?
  end

  def target_is?(target_sym)
    target_type.present? && (target_type.to_sym == target_sym)
  end

  def content_target?
    has_target? && !target_is?(:person)
  end

  def person_target?
    has_target? && target_is?(:person)
  end

  def verb_is?(verb_sym)
    return false unless verb
    verb.to_sym == verb_sym
  end


  private

  def process
    judge
    process_badges
    persist_op
  end

  def process_badges
    badges = app.badges.on

    badges.each do |badge|
      badge.process(self)
    end unless badges.blank?
  end

  def judge
    Hammurabi.new(self).judge
  end

  def persist_op
    unless op_data.blank?
      OperationLog.create!(:data => op_data, :activity => self, :app => app)
    end
  end

  def validate_reward_setting(verb, object_type = nil)
    object_type.present? ? validate_verb_object_type(verb, object_type) :  validate_verb(verb)
  end

  def validate_verb_object_type(verb, object_type)
    app.settings.rewards.send(verb).send(object_type)
    rescue Settings::MissingSetting
      validate_verb(verb)
  end

  def validate_verb(verb)
    return false unless verb

    app.settings.rewards.send(verb).send(:default)
    rescue Settings::MissingSetting
      errors.add("Verb #{verb}")
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
#  object_url          :string(255)
#  target_type         :string(255)
#  target_token        :string(32)
#  target_url          :string(255)
#  target_author_token :string(32)
#  mood                :string(25)
#  intensity           :integer(2)
#  created_at          :datetime
#  updated_at          :datetime
#

module Exceptions
  module Kandypot
    class UnknownActivity < StandardError; end
    class UnknownActivityCategory  < StandardError; end
  end
end
