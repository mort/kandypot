require File.expand_path('../../spec_helper', __FILE__)

describe MembersController, 'get' do
  before do
    @member = create(:member)
    @request.host = "#{@member.app.nicename}.example.com"
  end

  it 'should respond with not found to a bad app id' do
    authenticate_with_http_digest(@member.app.app_key, @member.app.app_token, @member.app.api_auth_realm)

    get :show, :id => @member.member_token, :app_id => 'foo', :subdomains => :app_id
    response.response_code.should == 404
  end

  it 'should respond with forbidden to no authentication' do
    get :show, :id => @member.member_token, :app_id => @member.app.nicename, :subdomains => :app_id
    response.response_code.should == 401
  end

end

describe MembersController, 'get /member' do
  before do
    @member = create(:member, :kandies_count => 20)
    @request.host = "#{@member.app.nicename}.example.com"

    authenticate_with_http_digest(@member.app.app_key, @member.app.app_token, @member.app.api_auth_realm)

    get :show,  {:id => @member.member_token, :app_id => @member.app.nicename, :subdomains => :app_id}
  end

  it 'should respond with success' do
    response.response_code.should == 200
  end

  it 'should respond with a jsonified hash' do
    ActiveSupport::JSON::decode(response.body).class.should == Hash
  end

  it 'should have three elements' do
    ActiveSupport::JSON::decode(response.body).keys.size.should == 3
  end

  it 'should carry the kandies count' do
    ActiveSupport::JSON::decode(response.body)['kandies_count'].should == 20
  end

  it 'should carry the member token' do
    ActiveSupport::JSON::decode(response.body)['member_token'].should == @member.member_token
  end


end


describe MembersController, 'get /members' do
  before do
    @app = create(:app)
    @request.host = "#{@app.nicename}.example.com"
    10.times { create(:member, :app => @app) }

    authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)

    get :index, :app_id => @app.nicename, :format => 'csv', :subdomains => :app_id
  end

  it 'should respond with success' do
    response.response_code.should == 200
  end

  it 'should respond with content type text/plain' do
    response.content_type.should == 'text/plain'
  end

  it 'should have the right number of lines' do
    csv = response.body
    arr = csv.split("\n")
    arr.size.should == 10
  end

  it 'should have the right number of cols' do
    csv = response.body
    arr = csv.split("\n")
    line = arr.first
    cols = line.split(',')

    cols.size.should == 3

  end

end

