module BadgeProcessors

  class Newbish < BaseProcessor
    # Previous logic at proccesor.rb (BaseProcessor)

    def initialize(activity, badge)
      super(activity, badge)
    end

    def process
      # No more work to do, let's call the parent's method directly
      concede_by_quantity
    end

  end

end
