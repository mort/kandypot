module BadgeProcessors
  
  class Cycle < BaseProcessor
    # Previous logic at proccesor.rb (BaseProcessor)
  
    def initialize(activity, badge)
      super(activity, badge)
    end
  
    def process

      # Base query is built (from the Processor initialization), let's prepare our custom query
         
      @extra_cond_str << " AND activities.activity_at > ?"
      @extra_cond_params << @period_qtty.send(@period_type.to_sym).ago
                  
      @cond_arr = [@cond_str+@extra_cond_str] + (@cond_params+@extra_cond_params)
                  
      concede_by_quantity
                     
    end
  end
end
