module BadgeProcessors
  class Cycle
    include BadgeProcessors::Aux
  
    def process(activity, badge)
      return if activity.category?(:singular)

      params = badge.params
    
      verb = params['verb']
      col = (verb == 'post') ? 'object_type' : 'target_type'
  
      period_type = params['period_type']
      period_qtty = params['period_qtty'].to_i
      n = params['n'].to_i
      ctype = params['sought_type']
  
      date_cond_str = ""
      date_cond_params = []          

  
      cond_str = "activities.app_id = ? AND activities.member_token = ?"
      cond_params = [activity.app_id, activity.member_token]

      unless params['sought_type'] == '*'
        cond_str << " AND activities.#{col} = ?"
        cond_params << params['sought_type']
      end

     prior_date = period_qtty.send(period_type.to_sym).ago
              
     Badge::BADGE_STREAK_TIME_PERIODS.each do |period|

        # Vamos a construir dinámicamente una cadena SQL tipo AND YEAR(activities.activity_at) = 2010
        # AND MONTH(activities.activity_at) = 5 AND ..
        date_cond_str << " AND #{period.upcase}(activities.activity_at) = ?"
        date_cond_params << activity.activity_at.send(period.to_sym)

        # En el momento en que llegamos al nivel de "granularidad" del badge (año, mes, semana, día, hora),
        # ya nos vamos
        break if (period_type == period)
      end                    
                      
  
      cond_arr = [cond_str+date_cond_str] + (cond_params+date_cond_params)

  
      count = Activity.count(:conditions => cond_arr)
      concede = (count >= n)
  
      Member.grant_badge(activity.member_token, badge) if concede             
  
  
    end
  end
end
