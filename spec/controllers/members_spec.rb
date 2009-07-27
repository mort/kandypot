require File.dirname(__FILE__) + '/../spec_helper'

describe MembersController, 'get' do
  before do
    @member = Member.make
  end
  
  it 'should respond with not found to a bad app id' do
    get :show, :id => @member.member_token, :app_id => 'foo'
    response.response_code.should == 404
  end

  it 'should respond with forbidden to no signature' do
    get :show, :id => @member.member_token, :app_id => @member.app.id
    response.response_code.should == 403
  end  
  
end

describe MembersController, 'get /member' do
  before do
    @member = Member.make(:kandies_count => 20)
    
    par = {'app_token' => @member.app.app_token, 'date_scope' => Time.now.midnight.utc.iso8601}
    par_str = par.sort.map{|j| j.join('=')}.join('&')
    str = Digest::SHA1.hexdigest(par_str)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @member.app.app_key, str)
    
    params = sign_request(@member.app)
    
    get :show,  {:id => @member.member_token, :app_id => @member.app.id}.merge(params)
  end
  
  it 'should respond with success' do  
    response.response_code.should == 200
  end
  
  it 'should respond with a jsonified hash' do
    ActiveSupport::JSON::decode(response.body).class.should == Hash
  end
  
  it 'should have two elements' do
    ActiveSupport::JSON::decode(response.body).keys.size.should == 2
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
    @app = App.make
    10.times { Member.make(:app => @app) }
    
    params = sign_request(@app)
    
    get :index, {:app_id => @app.id, :format => 'csv'}.merge(params)
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

