class OpData

  attr_accessor  :actor_token,  :activity_uuid, :do_reward, :do_transfer, :category, :p, :modulated_p, :reward_amount, :transfer_amount, :transfer_recipient_token

  def save!
    true
  end
  
  def [](attr)
    attr
  end

end