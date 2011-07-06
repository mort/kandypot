require File.dirname(__FILE__) + '/../spec_helper'

describe Hammurabi do
  
  it 'should be created all right' do
      @act = create(:act)
      @h = Hammurabi.new(@act)
  
      @h.should be_instance_of(Hammurabi)
      @h.actor.should be_instance_of(Member)
      @h.app.should == @act.app
      @h.p.should be_instance_of(Float)
      @h.activity.should === @act    
    end
  
  
  context 'judging' do
    
    before(:each) do
      
      @act = FactoryGirl.create(:act)
      @h = Hammurabi.new(@act)
      @op = @h.judge
    end
          
    it 'should return an operation log' do
      @op.should be_instance_of(OperationLog)  
      @op.data.should be_instance_of(Hash)    
      
      @op.data[:do_reward].should_not be_nil
      assert [TrueClass,FalseClass].include?(@op.data[:do_reward].class), @op.data[:do_reward].class
      
      @op.data[:do_transfer].should_not be_nil
      assert [TrueClass,FalseClass].include?(@op.data[:do_transfer].class), @op.inspect
      
      @op.data[:p].should_not be_nil
      @op.data[:modulated_p].should_not be_nil
      
      @op.data[:activity_uuid].should_not be_nil
      @op.data[:activity_uuid].should == @act.uuid
      
      @op.data[:actor_token].should_not be_nil
      @op.data[:actor_token].should == @act.actor_token
       
      @op.activity.should_not be_nil
      @op.activity == @act
      
      @op.app.should_not be_nil
      @op.app == @act.app
      
       
    end
    
    context 'a singular activity' do
      
      before(:each) do
        clean_db
        @act = FactoryGirl.create(:act)
      end
        
      context 'when rewarded' do

        before(:each) do
          Trickster.should_receive(:modulate).with(anything(), anything(), anything(), anything(), anything()).and_return(1)          
          @h = Hammurabi.new(@act)
          @h.stub!(:calculate_reward_amount).and_return(10)
          @op = @h.judge
        end
        
         it 'should mark do_reward as true' do
           @op.data[:do_reward].should == true
         end

         it 'should mark do_transfer as false' do
           @op.data[:do_transfer].should == false
         end

         it 'should have a reward amount' do
           @op.data[:reward_amount].should == 10
         end

      end

      context 'when no rewarded' do

        before(:each) do
          Trickster.should_receive(:modulate).with(anything(), anything(), anything(), anything(), anything()).and_return(0)
          @h = Hammurabi.new(@act)
          @h.stub!(:reward_amount).and_return(10)
          
          @op = @h.judge
        end
        
         it 'should mark reward as false' do
           @op.data[:do_reward].should == false
         end

         it 'should mark transfer as false' do
           @op.data[:do_transfer].should == false
         end

         it 'should have no reward amount' do
           @op.data[:reward_amount].should be_nil
         end

      end 
        
      
    
    end
    
    
    context 'a creation activity' do

       before(:each) do
         clean_db
         @act = FactoryGirl.create(:creation_act)
       end

       context 'when rewarded' do

         before(:each) do
           Trickster.should_receive(:modulate).with(anything(), anything(), anything(), anything(), anything()).and_return(1)          
           @h = Hammurabi.new(@act)
           @h.stub!(:calculate_reward_amount).and_return(10)
           @op = @h.judge
         end

          it 'should mark do_reward as true' do
            @op.data[:do_reward].should == true
          end

          it 'should mark do_transfer as false' do
            @op.data[:do_transfer].should == false
          end

          it 'should have a reward amount' do
            @op.data[:reward_amount].should == 10
          end

       end

       context 'when no rewarded' do

         before(:each) do
           Trickster.should_receive(:modulate).with(anything(), anything(), anything(), anything(), anything()).and_return(0)
           @h = Hammurabi.new(@act)
           @h.stub!(:reward_amount).and_return(10)

           @op = @h.judge
         end

          it 'should mark reward as false' do
            @op.data[:do_reward].should == false
          end

          it 'should mark transfer as false' do
            @op.data[:do_transfer].should == false
          end

          it 'should have no reward amount' do
            @op.data[:reward_amount].should be_nil
          end

       end 

    end
    
    
    context 'a reaction activity' do

       before(:each) do
         clean_db
         @act = FactoryGirl.create(:reaction_act)
       end

       context 'when rewarded' do

         before(:each) do
           Trickster.should_receive(:modulate).with(anything(), anything(), anything(), anything(), anything()).and_return(1)          
           @h = Hammurabi.new(@act)
           @h.stub!(:calculate_reward_amount).and_return(10)
           @h.stub!(:calculate_transfer_amount).and_return(1)
           @op = @h.judge
         end

          it 'should mark do_reward as true' do
            @op.data[:do_reward].should == true
          end

          it 'should mark do_transfer as true' do
            @op.data[:do_transfer].should == true
          end

          it 'should have a reward amount' do
            @op.data[:reward_amount].should == 10
          end
          
          it 'should have a transfer amount' do
            @op.data[:transfer_amount].should == 1
          end

       end

       context 'when no rewarded' do

         before(:each) do
           Trickster.should_receive(:modulate).with(anything(), anything(), anything(), anything(), anything()).and_return(0)
           @h = Hammurabi.new(@act)
           @h.stub!(:calculate_reward_amount).and_return(10)
           @h.stub!(:calculate_transfer_amount).and_return(1)

           @op = @h.judge
         end

          it 'should mark reward as false' do
            @op.data[:do_reward].should == false
          end

          it 'should mark transfer as false' do
            @op.data[:do_transfer].should == false
          end

          it 'should have no reward amount' do
            @op.data[:reward_amount].should be_nil
          end
          
         it 'should have no transfer amount' do
           @op.data[:transfer_amount].should be_nil
         end 

       end 



     end
            
  end
  
  
end

