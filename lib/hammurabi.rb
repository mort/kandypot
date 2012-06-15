#module Kandypot
 
  class Hammurabi
    
    attr_reader :activity, :app, :actor, :do_reward, :do_transfer, :transfer_recipient_token, :transfer_amount, :reward_amount, :modulated_p, :p
    
    def initialize(activity)
      @activity = activity
      @app = @activity.app
      @actor = @app.members.find_or_create_by_member_token(@activity.actor_token)
      @p = @app.settings.probabilities.default
      
      @recipient = if @activity.target_author_token
          @app.members.find_or_create_by_member_token(@activity.target_author_token) 
        elsif @activity.target_token
          @app.members.find_or_create_by_member_token(@activity.target_token) 
        else
          nil
        end
     
      @do_reward = @do_transfer = false
      @modulated_p = @reward_amount = @transfer_amount = @transfer_recipient_token = nil
      @op_data = {}
    end
      
    def judge
            
      case @activity.category 
        when 'singular', 'creation', 'action'
          reward(@app, @actor, @p, false)
        when 'reaction'
          reward(@app, @actor, @p, true) { @transfer_recipient_token = @activity.target_author_token }
        when 'interaction'
          reward(@app, @actor, @p, true) { @transfer_recipient_token = @activity.target_token }
        else
         raise Exceptions::UnknownActivity, method_name
      end
      
      data = {
        :actor_token => @activity.actor_token,
        :activity_uuid => @activity.uuid,
        :do_reward => @do_reward,
        :do_transfer => @do_transfer,
        :category => @activity.category,
        :p => @p,
        :modulated_p => @modulated_p,
      }
      
      if @do_reward
        
        data[:reward_amount] = @reward_amount 
        data[:actor_kandy_balance] = @actor.kandies_count + @reward_amount         
      
      else
      
        data[:actor_kandy_balance] = @actor.kandies_count 
      
      end
      
      if @do_transfer
        
        data[:transfer_amount] = @transfer_amount 
        data[:transfer_recipient_token] = @transfer_recipient_token
        data[:actor_kandy_balance] = data[:actor_kandy_balance] - @transfer_amount         
        data[:transfer_recipient_kandy_balance] = @recipient.kandies_count + @transfer_amount 

      else

        data[:transfer_recipient_kandy_balance] = @recipient.kandies_count

      end
      
      data[:reward_amount] = (@reward_amount - @transfer_amount) if @do_transfer
            
      @activity.op_data = data
      data
    end
    

    
    private
    
    def reward(app, actor, p, with_transfer = true)

       max = app.settings.probabilities.max
       min = app.settings.probabilities.min
  
       @modulated_p = Trickster::modulate(:p => p, :mood => @activity.mood, :intensity => @activity.intensity, :max => max, :min => min) 
       @reward_amount = Trickster::whim(calculate_reward_amount, @modulated_p)

       if @reward_amount
         @do_reward = true
         @transfer_amount = calculate_transfer_amount
         yield if block_given?
         @do_transfer = (with_transfer && (@activity.actor_token != @transfer_recipient_token))
       end

    end
    
    def calculate_transfer_amount
      percentage =  @app.settings.percentages.send(:default)
      ((@reward_amount.to_f*percentage.to_f/100)).ceil
    end
        
    def calculate_reward_amount
      t = @activity.target_type || @activity.object_type || :default
      @app.settings.rewards.send(@activity.verb).send(t)
      rescue Settings::MissingSetting
        @app.settings.rewards.send(@activity.verb).send(:default)
    end
          
  end
  
  module Exceptions
    class UnknownActivity < StandardError; end
    class UnknownActivityCategory < StandardError; end
  end
  
  class Trickster
    def self.whim(i, p = 0.8)
      coin_toss(p) ? i : nil
    end
    
    def self.coin_toss(p = 0.5)
      rand <= p
    end

    def self.modulate(options)
      
      p = options[:p] || 0.5
      mood = options[:mood] || 0
      intensity = options[:intensity] || 5
      max = options[:max] || 0.9
      min = options[:min] || 0.1
      
      p = p.to_f.send((mood == -1) ? :- : :+, Math::log10(intensity)/2) 
      p = sprintf("%.2f", p).to_f

      (p > max) ? max : ((p < min) ? min : p)

    end
  end
  
#end