# frozen_string_literal: true

require 'sidekiq'

require_relative "silent_retry/version"
require_relative "silent_retry/server_middleware"

module Sidekiq
  module SilentRetry
    class SilentError < StandardError; end

    def self.silent_retry_error_class
      @silent_retry_error_class ||= SilentError
    end

    def self.silent_retry_error_class=(error_class)
      @silent_retry_error_class = error_class
    end
  end
end
