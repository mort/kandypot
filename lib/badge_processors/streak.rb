module BadgeProcessors
  class Streak
    
    def process

      i = 0
    
      concede = false
    
      period_qtty.times do |i|

        # 1.day.ago / 2.months.ago / 3.years.ago
        prior_date = i.send(period_type.to_sym).ago

        BadgePeriodType.all.each do |period|
        
          # Vamos a construir dinámicamente una cadena SQL tipo AND YEAR(activities.activity_at) = 2010
          # AND MONTH(activities.activity_at) = 5 AND ..
          pname = period.name
          
          date_cond_str << " AND #{pname.upcase}(activities.activity_at) = ?"
          date_cond_params << prior_date.send(pname.to_sym)
        
          # En el momento en que llegamos al nivel de "granularidad" del badge (año, mes, semana, día, hora),
          # ya nos vamos
          break if (period_type == p.name)
        end


        cond_arr = [cond_str+date_cond_str] + (cond_params+date_cond_params)
      
        #Logger.new(STDOUT).info("cond_arr: #{cond_arr.inspect}")
        #Logger.new(STDOUT).info("-----")
                  
        date_cond_str = ''
        date_cond_params = []
      
        count = Activity.count(:conditions => cond_arr)
        concede = (count >= n)
      
      end
    
      if @concede
        member = Member.find_by_member_token(@activity.actor_token)
        @badge.grant(member)           
      end             
            
    end
  end
end