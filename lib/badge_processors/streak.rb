module BadgeProcessors
  
  class Streak < BaseProcessor
    # Previous logic at proccesor.rb (BaseProcessor)
    
    def initialize(badge, activity)
      super(activity, badge)
    end
    
    def process

      # Base query is built (from the Processor initialization), let's prepare our custom query

      i = 0
      
      @period_qtty.times do |i|

        # 1.day.ago / 2.months.ago / 3.years.ago
        prior_date = i.send(@period_type.to_sym).ago

        BadgePeriodType.all.each do |period|

          # Vamos a construir dinámicamente una cadena SQL tipo AND YEAR(activities.activity_at) = 2010
          # AND MONTH(activities.activity_at) = 5 AND ..

          pname = period.name
          @extra_cond_str << " AND #{pname.upcase}(activities.activity_at) = ?"
          @extra_cond_params << prior_date.send(pname.to_sym)

          # En el momento en que llegamos al nivel de "granularidad" del badge (año, mes, semana, día, hora),
          # ya nos vamos

          break if (@period_type == p.name)
        end

      
      end
      
      @cond_arr = [@cond_str+@extra_cond_str] + (@cond_params+@extra_cond_params)
      
      concede_by_qtty
      
    end
  end
end