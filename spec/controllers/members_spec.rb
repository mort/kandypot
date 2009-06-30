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

describe MembersController, 'a correct request' do
  before do
    @member = Member.make(:kandies_count => 20)
    str =  Digest::SHA1.hexdigest("#{@member.member_token}###{Time.now.midnight.to_s}")
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @member.app.app_key, str)
    get :show, :id => @member.member_token, :app_id => @member.app.id, :signature => signature
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