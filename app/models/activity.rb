# == Schema Information
# Schema version: 20090620163846
#
# Table name: activities
#
#  id                         :integer(4)      not null, primary key
#  credentials_app_token      :string(255)
#  credentials_signature      :string(255)
#  member_token               :string(255)
#  content_token              :string(255)
#  content_owner_member_token :string(255)
#  activity_type              :string(255)
#  content_type               :string(255)
#  content_source             :string(255)
#  ip                         :string(15)
#  activity_at                :datetime
#  processed_at               :datetime
#  proccessing_status         :integer(2)
#  created_at                 :datetime
#  updated_at                 :datetime
#

class Activity < ActiveRecord::Base
  ACTIVITY_TYPES = ['content_creation', 'reaction_comment', 'reaction_favorite', 'reaction_other']
  SIGNATURE_PARAMS = [:member_token, :content_token, :content_type, :content_source, :activity_type, :activity_at]
  
  
  validates_presence_of :credentials_app_token, :credentials_signature, :member_token, :content_token, :content_type, :content_source, :activity_type, :ip, :activity_at
  validates_presence_of :content_owner_member_token, :if => Proc.new {|act| (Activity.kind_of?(act.activity_type) == :reaction) }
  validates_inclusion_of :activity_type, :in => ACTIVITY_TYPES
  validate :authenticated?
  
  def self.kind_of?(activity_type)
    return false unless ACTIVITY_TYPES.include?(activity_type)
    return :content_creation if activity_type == 'content_creation'
    return :reaction if activity_type =~ /reaction_/
  end
    
  def authenticated?
    signature_params = self.attributes.reject {|k,v| !SIGNATURE_PARAMS.include?(k.to_sym)}
    packed_signature_params = App.pack_up_params_for_signature(signature_params)
    return App.authenticate(self.credentials_app_token, packed_signature_params, self.credentials_signature)
  end
  
end
