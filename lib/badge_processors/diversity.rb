# Diversity badges DON'T SUPPPORT LEVELS

module BadgeProcessors
  class Diversity < BaseProcessor
    
    def initialize(activity,badge)
      super(activity,badge)
    end
    
    def process
      return if @activity.category?(:singular)
      
      # Which type is the actity?
      activity_type = @activity.predicate_type
         
      # Which types are targeted by the badge?   
      predicate_types = @badge.predicate_types
      
      # Quit unless the activity type falls under the badge's concerns
      return unless predicate_types.include?(activity_type)
            
      # Remove the first predicate type from the badge types      
      predicate_types.delete(activity_type)
    
      # Find how many activities of the type
      count = Activity.count(:conditions => @cond_array)
      
      if right_count?(count, @qtty)
        @concede = true
        
        predicate_types.each do |type|

          cond = build_base_query(:predicate_type => type)
          count_prime = Activity.count(:conditions => cond)
          concede = (count_prime >= @qtty)
          break unless concede
        end
  
        if concede
          member = Member.find_by_member_token(@activity.actor_token)
          @badge.grant(member, @activity)           
        end
      end
        
    end
  end
end