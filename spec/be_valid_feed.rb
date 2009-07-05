class BeValidFeed
  require 'feed_validator'
  require 'tmpdir'
  require 'md5'

  def matches?(response)
    return true if validity_checks_disabled?
    v = W3C::FeedValidator.new()
    fragment = response.body
    filename = File.join Dir::tmpdir, 'feed.' + MD5.md5(fragment).to_s
    begin
      response = File.open filename do |f| Marshal.load(f) end
      v.parse(response)
    rescue   
      unless v.validate_data(fragment)
        @failure = " could not access w3 validator to validate the feed."
        return false
      end
      File.open filename, 'w+' do |f| Marshal.dump v.response, f end
    end
    v.valid?   
  end

  def description
    "be valid xhtml"
  end

  def failure_message
   @failure || " expected xhtml to be valid, but validation produced these errors:\n #{@message}"
  end

  def negative_failure_message
    " expected to not be valid, but was (missing validation?)"
  end

  private
    def validity_checks_disabled?
      ENV["NONET"] == 'true'
    end
end

def be_valid_feed
  BeValidFeed.new
end