# frozen_string_literal: true

require "rack/request"
require "rack/file"

module BreezyPDFLite::Intercept
  # Takes the App's response body, and submits it to the breezypdf lite endpoint
  # resulting in a file. File is then served with Rack::File
  class HTML < Base
    def call
      request = Rack::Request.new({})
      path = render_request_file.path

      Rack::File.new(path, response_headers).serving(request, path)
    end

    private

    def render_request
      @render_request ||= BreezyPDFLite::RenderRequest.new(body)
    end

    def render_request_file
      @render_request_file ||= render_request.to_file
    end

    def response_headers
      headers = {
        "Content-Type" => "application/pdf",
        "Content-Disposition" => render_request.response.header["Content-Disposition"]
      }

      headers["Set-Cookie"] = download_key if download_key

      @response_headers ||= headers
    end

    def download_key
      key = Rack::Utils.parse_query(env["QUERY_STRING"])["download_key"]

      return false unless key

      expires = (Time.now.utc + (60 * 10)).strftime("%a, %e %b %Y %H:%M:%S GMT")
      timestamp = Time.now.utc.to_i
      "breezy_pdf_downloaded_#{key}=#{timestamp}; Expires=#{expires}"
    end
  end
end
