module BadgeProcessors

  class Newbish < Processor

    def process
      concede_by_quantity(@activity, @badge, @qtty)
    end

  end

end
