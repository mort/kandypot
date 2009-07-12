# == Schema Information
# Schema version: 20090619222107
#
# Table name: members
#
#  id                     :integer(4)      not null, primary key
#  app_id                 :integer(4)
#  member_token           :string(255)     default(""), not null
#  deposits_count         :integer(4)      default(0), not null
#  transfers_count        :integer(4)      default(0), not null
#  kandies_count          :integer(4)      default(0), not null
#  kandy_ownerships_count :integer(4)      default(0), not null
#  created_at             :datetime
#  updated_at             :datetime
#

class Member < ActiveRecord::Base
  belongs_to :app
  
  has_many :kandy_ownerships

  has_many :kandies, :through => :kandy_ownerships, :conditions => ['kandy_ownerships.status = ?', KandyOwnership::STATUSES.index(:active)] do

    def pick(amount, method = :rand)
      options = {:limit => amount}

      case method
        when :fifo
          find(:all, options.merge(:order => 'kandies.created_at ASC'))      
        when :lifo
          find(:all, options.merge(:order => 'kandies.created_at DESC'))      
        when :rand
          random(:all, options)
      end
    end

  end

  has_many :operation_logs
  has_many :deposits, :class_name => 'OperationLog', :conditions => ['operation_type = ?', 'deposit']
  has_many :transfers, :class_name => 'OperationLog', :conditions => ['operation_type = ?', 'transfer']
  has_many :sent_transfers, :class_name => 'OperationLog', :foreign_key => 'sender_id', :conditions => ['operation_type = ?', 'transfer']


  after_create do |member|
    member.send_later(:do_welcome_deposit)
  end  

  def do_deposit(amount, subject)
    return false unless amount > 0
    amount.times { self.kandies.create }
    self.deposits.create(:operation_type => 'deposit', :amount => amount, :subject => subject)
  end
  
  def do_transfer(amount, recipient, subject)
    return false unless (amount > 0 && amount < self.kandies.count)
    transfer_kandies = self.kandies.pick(amount, :fifo)
    
    transfer_kandies.each do |k|
      k.current_ownership.expire
      recipient.kandies << k
    end 
    
    recipient.transfers.create(:operation_type => 'transfer', :amount => amount, :subject => subject, :sender => self)
    
  end
    
  def update_kandy_cache
    kc = self.kandies.count
    self.update_attribute(:kandies_count, kc)
  end
  
    
  def do_welcome_deposit
    amount = self.app.settings.amounts.deposits.welcome
    do_deposit(amount, 'Welcome deposit')
  end

end
