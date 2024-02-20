# frozen_string_literal: true

# Specialization of Faraday::Response::RaiseError that also logs the full HTTP
# response before raising
class Faraday::LogAndRaiseErrorMiddleware < Faraday::Response::RaiseError
  def on_complete(env)
    super
  rescue Faraday::Error => e
    Rails.logger.warn("Middleware::LogAndRaiseError: #{e.inspect}")
    if Rails.env.development?
      parsed_request = e.response[:request].except(:body)
      request_body = e.response[:request][:body]

      parsed_request[:body] = if request_body.present?
                                Oj.safe_load request_body
                              else
                                e.response[:request]
                              end

      ap [:request, parsed_request]
      ap [:response_body, e.response[:body]]
    end

    raise e
  end
end
