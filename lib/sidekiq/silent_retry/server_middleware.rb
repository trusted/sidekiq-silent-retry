# frozen_string_literal: true

module Sidekiq
  module SilentRetry
    class ServerMiddleware
      include Sidekiq::ServerMiddleware

      def call(_job_instance, job_payload, _queue)
        yield
      rescue => error
        raise error unless silent_retry_enabled?(job_payload, error)
        raise error if retries_exhausted?(job_payload) # if it's the last retry, raise the original error

        raise Sidekiq::SilentRetry.silent_retry_error_class, error.message
      end

      private

      def retries_exhausted?(job_payload)
        job_payload['retry_count'] == job_payload['retry'] - 1
      end

      def silent_retry_enabled?(job_payload, error)
        option = job_payload['silent_retry']

        case option
        when TrueClass, FalseClass
          option
        when Class
          error.is_a?(option)
        when String
          error.is_a?(Kernel.const_get(option))
        when Array
          option.any? { |klass| error.is_a?(Kernel.const_get(klass)) }
        else
          false
        end
      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.prepend Sidekiq::SilentRetry::ServerMiddleware
  end
end
