require 'net/http'
require 'net/http/persistent'

module Faraday
  class ClientService
    delegate :initialize_faraday_client, to: :class

    def self.initialize_faraday_client(
      url:,
      handlers: %i[multipart json],
      headers: {},
      url_params: nil,
      extra_exceptions_to_retry: [],
      override_retry_params: {},
      &block
    )
      service_name = self.class.module_parent.to_s

      faraday_params = {
        url:,
        headers: {
          "User-Agent": 'Bertrand Bike Tracker https://biketracker.dev',
          "Content-Type": 'application/json'
        }.merge(headers),
        # encodes foo: [1, 2] as '?foo=1&foo=2' instead of '&foo[]=1&foo[]=2'
        request: {
          params_encoder: Faraday::FlatParamsEncoder
        },
        params: url_params,
        ssl: {
          min_version: OpenSSL::SSL::TLS1_2_VERSION
        }
      }

      connection =
        Faraday.new(faraday_params) do |f|
          handlers.each { |handler| f.request handler }

          # Notably absent: Faraday::ClientError as 400s are typically due to
          # bad data
          exceptions_to_retry = [
            Errno::ECONNRESET,
            Errno::ETIMEDOUT,
            Errno::EHOSTUNREACH,
            Timeout::Error,
            Faraday::TimeoutError,
            Faraday::ConnectionFailed,
            Faraday::ServerError,
            Faraday::SSLError,
            Net::OpenTimeout,
            Net::ReadTimeout,
            Net::HTTP::Persistent::Error,
            IO::EINPROGRESSWaitWritable,
            OpenSSL::SSL::SSLErrorWaitReadable,
            OpenSSL::SSL::SSLError,
            Zlib::BufError
          ]

          exceptions_to_retry += extra_exceptions_to_retry

          retry_params = {
            methods: %i[post delete get head options put patch],
            interval: Rails.env.test? ? 0 : 1.5,
            backoff_factor: Rails.env.test? ? 0 : 2,
            max: Rails.env.test? ? 1 : 7
          }.merge(override_retry_params)

          f.request :retry,
                    retry_params.merge(
                      {
                        exceptions: exceptions_to_retry,
                        retry_block: lambda { |env, _options, _retries, _exc|
                          Rails.logger.debug("Level 2: Retrying #{service_name} API: #{env.status}")
                        }
                      }
                    )

          f.use Faraday::LogAndRaiseErrorMiddleware

          f.request :retry,
                    retry_params.merge(
                      {
                        retry_statuses: [408, 429],
                        retry_block: lambda { |env, _options, _retries, _exc|
                          Rails.logger.debug("Level 1: Retrying #{service_name} API: #{env.status}")
                        }
                      }
                    )

          f.adapter :net_http_persistent
        end

      yield connection.builder if block.present?

      # This call ensures two things:
      # 1) Freeze the middleware stack so no new middleware can be added.
      # 2) Instantiates the middleware (which are otherwise lazy loaded) to
      #    prevent multiple threads from accidentally creating multiple
      #    instances of middlewares.
      connection.builder.app

      connection
    end
  end
end
