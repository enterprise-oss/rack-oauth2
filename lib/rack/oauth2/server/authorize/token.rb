module Rack
  module OAuth2
    module Server
      class Authorize
        class Token < Abstract::Handler

          def call(env)
            @request  = Request.new(env)
            @response = Response.new(request)
            super
          end

          class Request < Authorize::Request
            def initialize(env)
              super
              @response_type = :token
            end
          end

          class Response < Authorize::Response
            attr_accessor :access_token, :expires_in, :scope

            def required_params
              super + [:access_token]
            end

            def finish
              if approved?
                params = {
                  :access_token => access_token,
                  :expires_in => expires_in,
                  :scope => Array(scope).join(' '),
                  :state => state
                }.delete_if do |key, value|
                  value.blank?
                end
                redirect_uri.fragment = if redirect_uri.fragment
                  [redirect_uri.fragment, params.to_query].join('&')
                else
                  params.to_query
                end
                redirect redirect_uri.to_s
              end
              super
            end
          end

        end
      end
    end
  end
end