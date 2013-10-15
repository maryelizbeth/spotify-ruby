require 'faraday'

module FaradayMiddleware
 
  class RaiseHttpException < Faraday::Middleware
    def call(env)
      @app.call(env).on_complete do |response|
        case response[:status].to_i
        when 400
          raise Spotify::BadRequest, error_message_400(response, "There was a syntax error somewhere in your request. Please make an edit and try again.")
        when 403
          raise Spotify::NotFound, error_message_400(response, "Spotify is rate-limiting you. Relax. Enjoy a tea. Try again in a little while.")
        when 404
          raise Spotify::NotFound, error_message_400(response, "We were unable to find what you were looking for.")
        when 500
          raise Spotify::InternalServerError, error_message_500(response, "The server encountered an unexpected issue.")
        when 502
          raise Spotify::ServiceUnavailable, error_message_500(response, "the api received an unexpected response.")
        when 503
          raise Spotify::ServiceUnavailable, error_message_500(response, "The Spotify api is temporarily unavailable. Make some tea. Try again in a bit.")
        end
      end
    end

    def initialize(app)
      super app
      @parser = nil
    end

    private

    def error_message_400(response)
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{response[:status]}#{error_response_body(response[:body])}"
    end

    def error_response_body(body)
      if not body.nil? and not body.empty? and body.kind_of?(String)
        body = ::JSON.parse(body)
      end

      if body.nil?
        nil
      elsif body['meta'] and body['meta']['error_message'] and not body['meta']['error_message'].empty?
        ": #{body['meta']['error_message']}"
      end
    end

    def error_message_500(response, body=nil)
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{[response[:status].to_s + ':', body].compact.join(' ')}"
    end
  end
end