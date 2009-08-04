class MembersController < ApplicationController
  before_filter :require_app
  CSV_FIELDS = %w(member_token kandies_count updated_at)
  
  def show
    logger.info("params id es #{params[:id]} #{params.inspect}" )
    @member = @app.members.find_by_member_token(params[:id])
    
    if @member     
      render :json => {:member_token => @member.member_token, :kandies_count => @member.kandies_count, :updated_at => @member.updated_at}, :status => :ok if stale?(:last_modified => @member.updated_at.utc, :etag => @member)
    else
      render :text => '', :status => :not_found  
    end
  end
  
  def index

    @members = @app.members.all :limit => Settings.apps.members.csv_limit, :order => 'updated_at DESC, member_token ASC, created_at ASC'
    
    if stale?(:last_modified => @app.updated_at.utc, :etag => @app)    
      respond_to do |format|
      format.csv {
         csv_string = FasterCSV.generate do |csv|
          @members.map { |r| CSV_FIELDS.map { |m| r.send m }  }.each { |row| csv << row }
        end
        send_data csv_string, :type => "text/plain", 
                  :filename=> "#{@app.nicename}_members-#{Time.now.utc.iso8601}.csv",
                  :disposition => 'inline'
        
      }
    end
    end
  end
  
end
