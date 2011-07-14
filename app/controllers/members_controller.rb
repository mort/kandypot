class MembersController < ApplicationController
  before_filter :require_auth
  CSV_FIELDS = %w(member_token kandies_count updated_at)
  
  def show    
    @member = @app.members.find_by_member_token(params[:id])
    
    if @member     
      render :json => {:member_token => @member.member_token, :kandies_count => @member.kandies_count, :updated_at => @member.updated_at}, :status => :ok if stale?(:last_modified => @member.updated_at.utc, :etag => @member)
    else
      render :text => '', :status => :not_found  
    end
  end
  
  def index

    params[:order] ||= 'kandies_count DESC'
    params[:per_page] ||= Settings.apps.members.csv_limit
    params[:page] ||= 1
    
    @members = @app.members.paginate(:all, :per_page => params[:per_page], :order => params[:order], :page => params[:page])

    if stale?(:last_modified => @app.updated_at.utc, :etag => @app)    
      options = { :format => params[:format], :per_page => params[:per_page], :order => params[:order] }

      respond_to do |format|
      format.csv {
       
        headers['Link'] = "#{app_members_url(@app, options.merge(:page => @members.previous_page))};rel=prev" unless @members.previous_page.nil?
        headers['Link'] = "#{app_members_url(@app, options.merge(:page => @members.next_page))};rel=next" unless @members.next_page.nil?
        
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
