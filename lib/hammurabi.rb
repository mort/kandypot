module Kandypot
  module Hammurabi
    def judge
      app = App.find_by_app_token(self.app_token)     
      member = app.members.find_or_create_by_member_token(self.member_token)
      p = app.settings.probabilities.default
      
      method_name = "judge_#{self.activity_type}"
      
      if self.respond_to?(method_name)
        self.send(method_name.to_sym, app, member, p) 
      else  
         #puts "judge_#{self.activity_type}"
        raise Kandypot::Exceptions::UnknownActivity, method_name
      end
    end
    
    def judge_creation(app, member, p)
      # Let's reward the creator of the content 
      s = self.content_type 
      n = app.settings.amounts.deposits.creation.respond_to?(s) ? s : 'default' 
      
      proposed_amount = app.settings.amounts.deposits.creation.send(n)
      amount = Trickster::whim(proposed_amount, p)
      member.do_deposit(amount, "content creation #{s}") unless amount.nil?
    end
    
    def judge_reaction(app, member, p)
      return if (self.member_b_token == member.member_token)
      content_owner = app.members.find_or_create_by_member_token(self.member_b_token)  
      # Let's reward the reactor
      
      s = self.category

      n = app.settings.amounts.deposits.reaction.respond_to?(s) ? s : 'default' 
      proposed_amount = app.settings.amounts.deposits.reaction.send(n)
      
      
      amount = Trickster::whim(proposed_amount, p)
      
      unless amount.nil?
        member.do_deposit(amount, "reaction #{s}")

        # Let's transfer from participant to the content's owner
        sender = member
        recipient = content_owner
        m =  app.settings.percentages.transfers.reaction.respond_to?(s) ? s : 'default'
      
        p = Trickster::modulate(p, self.mood, self.intensity, app.settings.probabilities.max, app.settings.probabilities.min) unless (self.mood.nil? || self.intensity.nil?)
                
        percentage = app.settings.percentages.transfers.reaction.send(m)
        proposed_transfer_amount = ((amount.to_f*percentage.to_f/100)).ceil
        
        transfer_amount = Trickster::whim(proposed_transfer_amount, p)

        sender.do_transfer(transfer_amount, recipient, "reaction #{s} (received)") unless transfer_amount.nil?
      end
    end

  end

  module Exceptions
    class UnknownActivity < StandardError; end
  end
end

class Trickster
  def self.whim(i, p = 0.8)
    (rand < p) ? i : nil
  end
  
  def self.modulate(p, mood, intensity, max, min)
     
     op = (mood == 'negative') ? '-' : '+'
     i = (Math::log10(intensity)/2)
     
     p = p.to_f.send(op, i) 

     p =  sprintf("%.2f", p).to_f
     
     return (p > max) ? max : ((p < min) ? min : p)
     
  end
end





