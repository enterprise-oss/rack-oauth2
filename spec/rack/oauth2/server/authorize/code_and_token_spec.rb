require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize::CodeAndToken do

  context "when authorized" do

    before do
      # NOTE: for some reason, test fails when called Rack::OAuth2::Server::Authorization::CodeAndToken directly
      @app = Rack::OAuth2::Server::Authorize.new(simple_app) do |request, response|
        response.approve!
        response.code = "authorization_code"
        response.access_token = "access_token"
      end
      @request = Rack::MockRequest.new @app
    end

    it "should redirect to redirect_uri with authorization code" do
      response = @request.get("/?response_type=code_and_token&client_id=client&redirect_uri=http://client.example.com/callback")
      response.status.should == 302
      response.location.should == "http://client.example.com/callback?code=authorization_code#access_token=access_token"
    end

  end

  context "when denied" do

    before do
      # NOTE: for some reason, test fails when called Rack::OAuth2::Server::Authorization::Code directly
      @app = Rack::OAuth2::Server::Authorize.new(simple_app) do |request, response|
        raise Rack::OAuth2::Server::Unauthorized.new(:access_denied, 'User rejected the requested access.', :redirect_uri => request.redirect_uri)
      end
      @request = Rack::MockRequest.new @app
    end

    it "should redirect to redirect_uri with error message" do
      response = @request.get("/?response_type=code_and_token&client_id=client&redirect_uri=http://client.example.com/callback")
      response.status.should == 302
      response.location.should == "http://client.example.com/callback?error_description=User+rejected+the+requested+access.&error=access_denied"
    end

  end

end