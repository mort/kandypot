module Kandypot
  module Badges
    module Processors
      
      module Aux
       def self.concede_by_quantity(activity, badge, n)
          params = badge.params

          cond_str = "activities.app_id = ? AND activities.member_token = ?"
          cond_params = [activity.app_id, activity.member_token]

          unless params['content_type'] == '*'
            cond_str << " AND activities.content_type = ?"
            cond_params << params['content_type']
          end

          cond_arr = [cond_str] + cond_params

          count = Activity.count(:conditions => cond_arr)

          Member.grant_badge(activity.member_token, badge) if (count == n)

        end
      end
      
      
      class WelcomeProcessor 
        def self.process(activity, badge)
          Kandypot::Badges::Processors::Aux.concede_by_quantity(activity, badge, 1)
        end
      end
      
      
      class NewbishProcessor 
        def self.process(activity, badge)
          Kandypot::Badges::Processors::Aux.concede_by_quantity(activity, badge, badge.params['n'])
        end
      end
      
      
       
      class DiversityProcessor 
        def self.process(activity, badge)
          

          params = badge.params            
          ctype = activity.content_type
          ctypes = params['content_types'].split(';')
          n = params['n']
          other_types = ctypes - [ctype]
    
          if ctypes.include?(ctype)
            count = Activity.count(:conditions => ['activities.app_id = ? AND activities.member_token = ? AND content_type = ?', activity.app_id, activity.member_token, ctype])
      
            if (count == n)
              concede = true
              other_types.each do |type|
                 count = Activity.count(:conditions => ['activities.app_id = ? AND activities.member_token = ? AND content_type = ?', activity.app_id, activity.member_token, ctype])
                  concede = (count >= n) 
               end
              Member.grant_badge(activity.member_token, badge) if concede             
  
            end
          end
        end
      end          

      class CycleProcessor
        def self.process(activity, badge)
          params = badge.params
          
          period_type = params['period_type']
          period_qtty = params['period_qtty'].to_i
          n = params['n'].to_i
          ctype = params['content_type']
          
          date_cond_str = ""
          date_cond_params = []          
    
          
          cond_str = "activities.app_id = ? AND activities.member_token = ?"
          cond_params = [activity.app_id, activity.member_token]

          unless params['content_type'] == '*'
            cond_str << " AND activities.content_type = ?"
            cond_params << params['content_type']
          end

         prior_date = period_qtty.send(period_type.to_sym).ago
                      
         Badge::BADGE_SPREE_TIME_PERIODS.each do |period|

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
      
      class SpreeProcessor
        def self.process(activity, badge)
          
          
          params = badge.params
          
          period_type = params['period_type']
          period_qtty = params['period_qtty'].to_i
          n = params['n'].to_i
          ctype = params['content_type']
          
          date_cond_str = ""
          date_cond_params = []          
                    
          cond_str = "activities.app_id = ? AND activities.member_token = ?"
          cond_params = [activity.app_id, activity.member_token]

          unless params['content_type'] == '*'
            cond_str << " AND activities.content_type = ?"
            cond_params << params['content_type']
          end
          
          i = 0
          
          concede = false
          
          period_qtty.times do |i|

            # 1.day.ago / 2.months.ago / 3.years.ago
            prior_date = i.send(period_type.to_sym).ago

            Badge::BADGE_SPREE_TIME_PERIODS.each do |period|
              
              # Vamos a construir dinámicamente una cadena SQL tipo AND YEAR(activities.activity_at) = 2010
              # AND MONTH(activities.activity_at) = 5 AND ..

              date_cond_str << " AND #{period.upcase}(activities.activity_at) = ?"
              date_cond_params << prior_date.send(period.to_sym)
              
              # En el momento en que llegamos al nivel de "granularidad" del badge (año, mes, semana, día, hora),
              # ya nos vamos
              break if (period_type == period)
            end


            cond_arr = [cond_str+date_cond_str] + (cond_params+date_cond_params)
            
            #Logger.new(STDOUT).info("cond_arr: #{cond_arr.inspect}")
            #Logger.new(STDOUT).info("-----")
                        
            date_cond_str = ''
            date_cond_params = []
            
            count = Activity.count(:conditions => cond_arr)
            concede = (count >= n)
            
          end
          
            Member.grant_badge(activity.member_token, badge) if concede             
                  
        end
      end


    end
  end
end
