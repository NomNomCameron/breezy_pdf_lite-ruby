# frozen_string_literal: true

module BreezyPDFLite::Intercept
  # :nodoc
  class Base
    attr_reader :body, :env

    def initialize(body, env)
      @body = body
      @env = env
    end
  end
end
