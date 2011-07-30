require File.dirname(__FILE__) + '/../spec_helper'


describe Badge do
    
    before(:each) do
      @badge = create(:newbish_badge)
    end
    
    it 'should be valid' do
      @badge.should be_valid
    end
  
    it 'should have an array of predicate types' do
      @badge.predicate_types.should be_instance_of(Array)
    end
  
    it 'should have a predicate type' do
      @badge.predicate_type.should be_instance_of(String)
      @badge.predicate_type.should == '*'
    end
    
    it 'should guess its type' do
      @badge.badge_type?(@badge.badge_type).should be_true
    end
    
    it 'should instantiate its own processor' do
      @badge.send(:processor).should ==  "BadgeProcessors::#{@badge.badge_type.capitalize}".constantize
    end
  
    it 'should be grantable' do
      act = Activity.new
      
      member = create(:member)
      @badge.grant(member, act).should be_true
    end
  
    it 'shouldnt be grantable twice if its not repeatable' do
      act = mock_model(Activity)
      act.stub!(:op_data).and_return({})
      
      member = mock_model(Member)
      member.should_receive(:can_has_badge?).with(@badge).and_return(false)
      @badge.grant(member, act).should be_false
    end
    
    it 'should be grantable twice if its repeatable' do
      act = mock_model(Activity)
      act.stub!(:op_data).and_return({})
      
      member = create(:member)
      member.should_receive(:can_has_badge?).and_return(true)
      repeatable_badge = create(:newbish_badge, :repeatable => true)
      repeatable_badge.grant(member,act).should be_true
    end
  
  
  
end

# == Schema Information
#
# Table name: badges
#
#  id              :integer(4)      not null, primary key
#  app_id          :integer(4)
#  badge_type      :string(255)
#  title           :string(255)
#  description     :string(255)
#  params          :text
#  status          :integer(1)
#  created_at      :datetime
#  updated_at      :datetime
#  category        :string(255)
#  verb            :string(255)
#  predicate_types :string(255)
#  qtty            :integer(4)
#  variant         :string(1)
#  period_type     :string(2)
#  period_variant  :string(2)
#  badge_scope     :string(25)
#  repeatable      :boolean(1)      default(FALSE), not null
#  p               :float           default(1.0), not null
#

