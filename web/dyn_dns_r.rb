require 'roda'
require 'api-auth'
require_relative '../db/models'
# The Main Namespace
module DynDnsR
  L 'a'
  L 'alias'
  # Our Web App
  class Api < Roda
    plugin :halt
    use Rack::Session::Cookie, secret: ENV['SECRET_KEY'] || ApiAuth.generate_secret_key # rubocop:disable Metrics/LineLength
    route do |r|
      r.root do
        r.redirect '/api'
      end

      r.on 'api' do
        r.is do
          'Api Home, nothing of interest'
        end

        # Authentication required for everything else
        access_id = ApiAuth.access_id request
        r.halt 403, 'Unable to authenticate' unless access_id
        @auth_user = User[access_id]
        r.halt 403, 'Unable to authenticate' unless @auth_user
        r.halt 403, 'Unable to authenticate' unless ApiAuth.authentic?(request, @auth_user.secret) # rubocop:disable Metrics/LineLength

        r.on 'test' do
          "You are authenticated #{@auth_user.name}"
        end

        r.on ':verb/:host/:ip/:ttl' do |verb, host, ip, ttl|
          r.halt 406, 'Unsupported action' unless %w(a alias).include? verb
          obj = case verb
                when 'a'
                  DynDnsR::A
                when 'alias'
                  DynDnsR::Alias
                end
          r.post do
            success = obj.create host, ip, ttl
            if success
              'Success'
            else
              r.halt 406, "Unable to create #{verb} record"
            end
          end
        end
      end
    end
  end
end
