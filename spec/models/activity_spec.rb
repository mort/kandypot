require File.expand_path('../../spec_helper', __FILE__)


describe Activity do
  it "should have an uuid by default" do
    @act = build(:act)
    @act.stub!('validate_verb').and_return(true)
    @act.save!

    @act.uuid.should_not be_blank
  end

  it "should call #process method after being creatd" do
    @act = build(:act)
    @act.stub!('validate_verb').and_return(true)
    @act.should_receive(:process)
    @act.save!
  end

  context "when its application has a badge" do
    before do
      @app = create(:app)
      @member = create(:member, :app => @app)
      @badge = create(:diversity_badge, :app => @app, :predicate_types => 'foo;bar;wadus')
    end

    describe "#process_badges method" do
      it "should call #process on each badge" do
        badges = double()
        badges.stub('on').and_return([@badge])
        @app.stub('badges').and_return(badges)
        @badge.should_receive(:process).with(any_args()).and_return(true)
        @act = create(:creation_act, :app => @app, :actor_token => @member.member_token, :object_type => 'foo')
      end
    end

    it "should have an associated operation log when created" do
      @act = create(:creation_act, :app => @app, :actor_token => @member.member_token, :object_type => 'foo')

      @act.operation_log.should_not be_nil
      @act.operation_log.app.should == @app
      @act.operation_log.data.should == @act.op_data
    end
  end

  describe "#process method" do
    before do
      @activity = Activity.new
    end

    it "should call #judge" do
      @activity.stub(:process_badges).and_return(true)
      @activity.stub(:persist_op).and_return(true)
      @activity.should_receive(:judge)
      @activity.send(:process)
    end

    it "should call #process_badges" do
      @activity.stub(:judge).and_return(true)
      @activity.stub(:persist_op).and_return(true)
      @activity.should_receive(:process_badges)
      @activity.send(:process)
    end

    it "should call #persist_opt" do
      @activity.stub(:judge).and_return(true)
      @activity.stub(:process_badges).and_return(true)
      @activity.should_receive(:persist_op)
      @activity.send(:process)
    end
  end

  describe "#judge method" do
    it "should call #judge method from Hammurabi" do
      a = Activity.new
      hammurabi = double()
      Hammurabi.should_receive(:new).with(a).and_return(hammurabi)
      hammurabi.should_receive(:judge).and_return(true)
      a.send(:judge)
    end
  end
end

describe Activity, 'singular' do
  before do
    @act = build(:act)
    @act.stub!('validate_verb').and_return(true)
    @act.save!
  end

  it 'should be valid' do
    @act.should be_valid
  end

  it 'should know its own verb' do
    @act.verb_is?(@act.verb.to_sym).should == true
  end

  it 'should have the right category' do
    @act.guess_category.should == 'singular'
  end

  it 'should not have an object' do
    @act.no_object?.should == true
  end

  it 'should not have a target' do
    @act.no_target?.should == true
  end

end


describe Activity, 'creation' do
  before do
    @act = build(:creation_act)
    @act.stub!('validate_verb').and_return(true)
    @act.save!
  end

  it 'should be valid' do
    @act.should be_valid
  end

  it 'should know its own verb' do
    @act.verb_is?(@act.verb.to_sym).should == true
  end

  it 'should have the right category' do
    @act.guess_category.should == 'creation'
  end

  it 'should not have a target' do
    @act.has_object?.should == true
  end

  it 'should have the right predicate' do
    @act.predicate_attr.should == :object_type
    @act.predicate_type.should == @act.object_type
  end

end


describe Activity, 'reaction' do
  before do
    @act = build(:reaction_act)
    @act.stub!('validate_verb').and_return(true)
    @act.save!
  end

  it 'should be valid' do
    @act.should be_valid
  end

  it 'should have the right category' do
    @act.guess_category.should == 'reaction'
  end

  it 'should have a target' do
    @act.has_target?.should == true
  end

  it 'should have a content target' do
    @act.content_target?.should == true
  end

  it 'should have a url for the target' do
    @act.target_url.should_not be_nil
  end

  it 'should have a token for the target author' do
    @act.target_author_token.should_not be_nil
  end

  it 'should have the right predicate' do
    @act.predicate_attr.should == :target_type
    @act.predicate_type.should == @act.target_type
  end

end


describe Activity, 'interaction' do
  before do
    @act = build(:interaction_act)
    @act.stub!('validate_verb').and_return(true)
    @act.save!
  end

  it 'should be valid' do
    @act.should be_valid
  end

  it 'should have the right category' do
    @act.guess_category.should == 'interaction'
  end

  it 'should have a target' do
    @act.has_target?.should == true
  end

  it 'should have a person target' do
    @act.person_target?.should == true
  end

  it 'should have a token for the target' do
    @act.target_token.should_not be_nil
  end

  it 'should not have a token for the target author' do
    @act.target_author_token.should be_nil
  end

end


describe Activity, 'badly formed' do

  it 'should not be valid without an actor_token and verb' do
    @act = build(:act, :actor_token => nil, :verb => nil)
    @act.should_not be_valid
  end

  context 'creation' do

    it 'should not be valid without an object' do
      @act = build(:creation_act, :object_url => nil)
      @act.should_not be_valid
    end

  end

  context 'reaction' do

    it 'should not be valid without a target' do
      @act = build(:reaction_act, :target_url => nil)
      @act.should_not be_valid
    end

    it 'should not be valid without a target author' do
      @act = build(:reaction_act, :target_author_token => nil)
      @act.should_not be_valid
    end

  end

  context 'interaction' do

    it 'should not be valid without a target' do
      @act = build(:interaction_act, :target_token => nil)
      @act.stub!('validate_verb').and_return(true)

      @act.should_not be_valid
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

