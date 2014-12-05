require 'roda'
require 'api-auth'
require_relative '../db/models'
require 'json'
# The Main Namespace
module DynDnsR
  Api = Class.new(Roda)
  # Our Web App
  class Api
    plugin :halt
    use Rack::Session::Cookie, secret: ENV['SECRET_KEY'] || ApiAuth.generate_secret_key # rubocop:disable Metrics/LineLength
    SUPPORTED_ACTIONS = %w(hostname alias)

    # for the main api actions of hostname and alias
    # TODO: add cname support
    def obj_from_action(action)
      return false unless SUPPORTED_ACTIONS.include? action
      case action
      when 'hostname'
        DynDnsR::Equal
      when 'alias'
        DynDnsR::A
      else
        DynDnsR.log.warn("Unimplemented method #{action}")
        false
      end
    end

    # All the action is here
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

        r.on 'host/:host' do |host|
          r.get do
            Equal.find(host: host).values.to_json
          end
        end

        r.on ':action/:host/:ip/:ttl' do |action, host, ip, ttl|
          obj = obj_from_action action
          r.halt 406, 'Unsupported action' unless obj
          r.post do
            success = obj.create_record @auth_user.id, host, ip, ttl
            if success
              'Success'
            else
              r.halt 406, "Unable to create #{action} record"
            end
          end
        end
      end
    end
  end
end
