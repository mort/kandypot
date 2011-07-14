module BadgeProcessors
  class Processor
    #include BadgeProcessors::Aux
  
    attr_reader :cond_array, :cond_params, :cond_str, :concede, :badge, :activity
  
    def initialize(activity, badge)
      @activity = activity
      @badge = badge
      @cond_array = @cond_params = []
      @cond_str = ''
      @concede = false
      @qtty = badge.qtty
      
      build_query
      
    end
  
    def build_query(options = {})
      
      @cond_str = '1 '
      @cond_params = []
  
      col = @activity.predicate_attr.to_s
      scp = BadgeScope.find(@badge.badge_scope).name
      
      predicate_type = options[:predicate_type] || @badge.predicate_type
      verb = options[:verb] || @badge.verb 
      actor_token = options[:actor_token] || @activity.actor_token
      app_id = options[:app_id] || @badge.app_id

      unless scp == 'global'
        @cond_str << "AND activities.app_id = ? "
        @cond_params << app_id
      end

     if scp == 'member' 
        @cond_str << "AND activities.actor_token = ?"
        @cond_params << actor_token
      end

      unless verb == '*'
        @cond_str << " AND activities.verb = ?"
        @cond_params << verb
      end

      unless predicate_type == '*'
        @cond_str << " AND activities.#{col} = ?"
        @cond_params << predicate_type
      end

      @cond_arr = [@cond_str] + @cond_params
      @cond_arr
    end
    
    def concede_by_quantity(act, badge, n)

      count = Activity.count(:conditions => @cond_arr)
  
      if right_count?(count, @qtty)
        @concede = true
        member = Member.find_by_member_token(@activity.actor_token)
        @badge.grant(member)
      end
    
    end

    def right_count?(received, expected)
      badge.repeatable? ? (received % expected == 0) : (received == expected)
    end
  
  
  
  end
end