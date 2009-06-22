module Kandypot
  module Hammurabi
    def judge
      app = App.find_by_app_token(self.credentials_app_token)     
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
    
    def judge_content_creation(app, member, p)
      # Let's reward the creator of the content  
      proposed_amount = app.settings.amounts.deposits.content_creation
      amount = Trickster::whim(proposed_amount, p)
      member.do_deposit(amount, 'content_creation') unless amount.nil?
    end
    
    def judge_reaction_comment(app, member, p)
      return if (self.content_owner_member_token == member.member_token)
      content_owner = app.members.find_or_create_by_member_token(self.content_owner_member_token)  
      # Let's reward the reactor
      proposed_amount = app.settings.amounts.deposits.send('reaction_comment')
      amount = Trickster::whim(proposed_amount, p)
      unless amount.nil?
        member.do_deposit(amount, 'reaction_comment')

        # Let's transfer from participant to the content's owner
        sender = member
        recipient = content_owner
        proposed_transfer_amount = app.settings.amounts.transfers.send('reaction_comment')
        transfer_amount = Trickster::whim(proposed_transfer_amount, p)

        sender.do_transfer(transfer_amount, recipient, 'reaction_comment (received)') unless transfer_amount.nil?
      end
    end

  
    
  end

  module Exceptions
    class UnknownActivity < StandardError; end
  end
end

class Trickster
  def self.whim(i,p = 0.8)
    (rand < p) ? i : nil
  end
end





