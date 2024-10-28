# frozen_string_literal: true

module Sidekiq
  module SilentRetry
    class ServerMiddleware
      include Sidekiq::ServerMiddleware

      def call(_job_instance, job_payload, _queue)
        yield
      rescue StandardError => e
        raise e unless silent_retry_enabled?(job_payload, e)
        raise e if should_warn?(job_payload)

        raise Sidekiq::SilentRetry.silent_retry_error_class, e.message
      end

      private

      def should_warn?(job_payload)
        retry_count = job_payload["retry_count"]

        return false if retry_count.nil?

        retry_count >= warn_after(job_payload)
      end

      def warn_after(job_payload)
        job_payload["warn_after"]&.to_i || job_payload["retry"] - 1
      end

      def silent_retry_enabled?(job_payload, error)
        option = job_payload["silent_retry"]

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
