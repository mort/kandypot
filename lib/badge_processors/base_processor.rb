module BadgeProcessors
  class BaseProcessor
  
    attr_reader :cond_array, :cond_params, :cond_str, :extra_cond_params, :extra_cond_str, :concede, :badge, :activity, :level
  
    def initialize(activity, badge)

      @activity = activity
      @badge = badge
      
      Badge::PARAMS_FIELDS.each { |param| instance_variable_set("@#{param}".to_sym, @badge.send(param.to_sym)) }
      
      @cond_array = @cond_params = @extra_cond_params = []
      @cond_str = @extra_cond_str =''
      @concede = false
      @level = nil
      
      build_base_query
    end
  
    #private

    def build_base_query(options = {})
      
      @cond_str = '1 '
      @cond_params = []
  
      col = @activity.predicate_attr.to_s
      scp = BadgeScope.find(@badge.badge_scope).name
      
      predicate_types = options[:predicate_types] || @badge.predicate_types
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

      if verb != '*'
        @cond_str << " AND activities.verb = ?"
        @cond_params << verb
      end

      if !@activity.category?(:singular) and predicate_types && predicate_types != '*'
        @cond_str << " AND activities.#{col} IN (?)"
        @cond_params << predicate_types
      end

      @cond_arr = [@cond_str] + @cond_params

    end
    
    def concede_by_quantity

      count = Activity.count(:conditions => @cond_arr)
  
      if concede?(count)
        @concede = true
        
        # Let's assign a badge level if the badge is repeatable
        @level = level_calc(count) if @badge.repeatable? 
        
        member = Member.find_by_member_token(@activity.actor_token)
        @badge.grant(member, @activity, @level) if member
      end
    
      return @concede
    end

    def concede?(count)
      Trickster.coin_toss(@badge.p) && right_count?(count, @qtty) && level_check(count)
    end

    def right_count?(received, expected)  
      @badge.repeatable? ? (received % expected == 0) : (received == expected)
    end
    
    def level_calc(count)
      count / @qtty
    end
    
    def level_check(count)
      return true if !@badge.repeatable? || @badge.max_level.nil?
      level_calc(count) <= @badge.max_level     
    end
    
  end
end