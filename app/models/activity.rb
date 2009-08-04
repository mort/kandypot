# == Schema Information
# Schema version: 20090702181526
#
# Table name: activities
#
#  id                 :integer(4)      not null, primary key
#  app_token          :string(255)
#  signature          :string(255)
#  member_token       :string(255)
#  content_token      :string(255)
#  member_b_token     :string(255)
#  activity_type      :string(255)
#  content_type       :string(255)
#  content_source     :string(255)
#  ip                 :string(15)
#  activity_at        :datetime
#  processed_at       :datetime
#  proccessing_status :integer(2)
#  created_at         :datetime
#  updated_at         :datetime
#  category           :string(255)
#

class Activity < ActiveRecord::Base
  require 'hammurabi'
  include Kandypot::Hammurabi
  
  ACTIVITY_TYPES = ['creation', 'reaction', 'relationship']
  MOOD_TYPES = ['positive', 'negative', 'neutral']
  CONTENT_SOURCES = %w(ugc editorial)
  
  belongs_to :app
  
  # common
  validates_presence_of  :member_token, :activity_type, :ip, :activity_at
  validates_inclusion_of :activity_type, :in => ACTIVITY_TYPES
  
  
  # mood and intensity in reactions (for @limalimon)
  validates_inclusion_of :mood, :in => MOOD_TYPES, :allow_nil => true, :if => Proc.new {|act| act.activity_type == 'reaction'}
  validates_numericality_of :intensity, :allow_nil => true, :if => Proc.new {|act| act.activity_type == 'reaction'}

  # reaction and relationship attrs
  validates_presence_of :member_b_token, :category, :if => Proc.new {|act| %w(reaction relationship).include?(act.activity_type) }
  
  # creation and reaction attrs
  validates_presence_of :content_token, :content_type, :content_source, :if => Proc.new {|act| %w(reaction creation).include?(act.activity_type) }

  validates_inclusion_of :content_source, :in => CONTENT_SOURCES, :allow_nil => true

  
  after_create do |activity|
    activity.send_later(:judge)
  end
  
end
