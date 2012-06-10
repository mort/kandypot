module BadgeProcessors
  class Processor
  
    attr_reader :cond_array, :cond_params, :cond_str, :concede, :badge, :activity, :level
  
    def initialize(activity, badge)
      @activity = activity
      @badge = badge
      @cond_array = @cond_params = []
      @cond_str = ''
      @concede = false
      @qtty = badge.qtty
      @level = nil
      
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
  
      if concede?(count, @qtty, @badge)
        
        # Let's assign a badge level if the badge is repeatable
        @level = level_calc(count, @qtty) if @badge.repeatable? 
        
        @concede = true
        member = Member.find_by_member_token(@activity.actor_token)
        @badge.grant(member, act, @level)
      end
    
    end

    def concede?(count, qtty, badge)
      Trickster.coin_toss(badge.p) && right_count?(count, qtty, badge) && level_check(count, qtty, badge)
    end

    def right_count?(received, expected, badge)  
      badge.repeatable? ? (received % expected == 0) : (received == expected)
    end
    
    def level_calc(count, qtty)
      count / qtty
    end
    
    def level_check(count, qtty, badge)
      return true if !badge.repeatable?       
      max_level = badge.max_level || 3
      level_calc(count,qtty) <= max_level      
    end
    
  end
end