module BadgeProcessors
  class Welcome
    include BadgeProcessors::Aux
    
    attr_reader :cond_array, :cond_params, :cond_str, :concede, :badge, :activity
    
    def initialize(activity, badge)
      @activity = activity
      @badge = badge
      @cond_array = @cond_params = []
      @cond_str = ''
      @concede = false
    end
    
    def process
      concede_by_quantity(@activity, @badge, 1)
    end
  end
end