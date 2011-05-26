module Kandypot
 
  module Hammurabi
    def judge
      member = app.members.find_or_create_by_member_token(self.actor_token)
      p = app.settings.probabilities.default
            
      case self.category 
        when 'singular', 'creation'
          reward(app, member, p, false)
        when 'reaction'
          reward(app, member, p, true) { 
            recipient_token = self.object_author_token
            subject = "reaction #{s} (received)"
          }
        when 'interaction'
          reward(app, member, p, true) { 
            recipient_token = self.object_token 
            subject = "relationship #{s} (received)"
          }
        else
         raise Kandypot::Exceptions::UnknownActivity, method_name
      end
      
    end
        
    def reward(app, member, p, with_transfer = true, &block)
       max = app.settings.probabilities.max
       min = app.settings.probabilities.min
  
       modulated_p = Trickster::modulate(p, self.mood, self.intensity, max, min) 
       amount = Trickster::whim(self.reward, modulated_p)

       if (!amount.nil? && with_transfer)
         member.do_deposit(amount, self.category) 
         
         percentage =  app.settings.percentages.send(:default)
         transfer_amount = ((amount.to_f*percentage.to_f/100)).ceil

         yield(block)

         recipient = app.members.find_or_create_by_member_token(recipient_token)          
         
         unless ((member == recipient) || transfer_amount.nil?) do
           member.do_transfer(transfer_amount, recipient, subject) 
         end
      
      end

    end
    
      
  end
  
  module Exceptions
    class UnknownActivity < StandardError; end
  end
  
  class Trickster
    def self.whim(i, p = 0.8)
      (rand < p) ? i : nil
    end

    def self.modulate(p, max, min, mood = 'neutral', intensity = 1)
       return p
       op = (mood == 'negative') ? '-' : '+'
       i = (Math::log10(intensity)/2)

       p = p.to_f.send(op, i) 

       p =  sprintf("%.2f", p).to_f

       return (p > max) ? max : ((p < min) ? min : p)

    end
  end
  
end

