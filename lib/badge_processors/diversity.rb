module BadgeProcessors
  class Diversity < Processor
    
    def process
      return if @activity.category?(:singular)
      
      # Which type is the actity?
      ctype = @activity.predicate_type
         
      # Which types are targeted by the badge?   
      ctypes = @badge.predicate_types
      
      # Quit unless the activity type falls under the badge's concerns
      return unless ctypes.include?(ctype)
            
      # Remove the first predicate type from the badge types      
      ctypes.delete(@badge.predicate_type)
    
      # Find how many activities of the type
      count = Activity.count(:conditions => @cond_array)
      
      if count == @qtty
        @concede = true
        
        ctypes.each do |type|

          cond = build_query(:predicate_type => type)
          count_prime = Activity.count(:conditions => cond)
          @concede = (count_prime >= @qtty)
          break unless @concede
        end
  
        if @concede
          member = Member.find_by_member_token(@activity.actor_token)
          @badge.grant(member)           
        end
      end
        
    end
  end
end