# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module TdxFeedbackGem
  # Define a base error if the main gem file hasn't been loaded yet
  class Error < StandardError; end unless defined?(TdxFeedbackGem::Error)

  class Client
    class HttpError < Error
      attr_reader :status, :body

      def initialize(message, status:, body: nil)
        super(message)
        @status = status
        @body = body
      end
    end

    def initialize(base_url:, token_url:, client_id:, client_secret:, scope: 'tdxticket')
      @base_url = base_url&.chomp('/')
      @token_url = token_url
      @client_id = client_id
      @client_secret = client_secret
      @scope = scope
      @token = nil
      @token_expires_at = Time.at(0)
    end

    def create_ticket(app_id:, payload: {}, params: {})
      path = "/#{app_id}/tickets"
      post_json(path, payload, params: params)
    end

    def post_feed(app_id:, ticket_id:, payload: {})
      path = "/#{app_id}/tickets/#{ticket_id}/feed"
      post_json(path, payload)
    end

    private

    def ensure_token!
      return if @token && Time.now < (@token_expires_at - 60)

      uri = URI(@token_url)
      req = Net::HTTP::Post.new(uri)
      req.basic_auth(@client_id, @client_secret)
      req.set_form_data('grant_type' => 'client_credentials', 'scope' => @scope)

      res = http_request(uri, req)
      data = begin
        JSON.parse(res.body)
      rescue StandardError
        {}
      end
      @token = data['access_token']
      raise HttpError.new('OAuth token missing', status: res.code.to_i, body: res.body) unless @token

      expires_in = data['expires_in'] || 3600
      @token_expires_at = Time.now + expires_in.to_i
    end

    def get_json(path, params: {})
      ensure_token!
      uri = build_uri(path, params)
      req = Net::HTTP::Get.new(uri)
      authorize!(req)
      req['Accept'] = 'application/json'
      res = http_request(uri, req)
      parse_json(res)
    end

    def post_json(path, body, params: {})
      ensure_token!
      uri = build_uri(path, params)
      req = Net::HTTP::Post.new(uri)
      authorize!(req)
      req['Content-Type'] = 'application/json'
      req['Accept'] = 'application/json'
      req.body = JSON.dump(body)
      res = http_request(uri, req)
      parse_json(res)
    end

    def authorize!(req)
      req['Authorization'] = "Bearer #{@token}"
    end

    def build_uri(path, params)
      raise ArgumentError, 'base_url is missing' unless @base_url

      uri = URI(@base_url + path)
      unless params.nil? || params.empty?
        q = URI.decode_www_form(uri.query.to_s) + params.map { |k, v| [k.to_s, v.to_s] }
        uri.query = URI.encode_www_form(q)
      end
      uri
    end

    def http_request(uri, req)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.read_timeout = 15
      http.open_timeout = 5
      res = http.request(req)
      unless res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPCreated)
        raise HttpError.new("HTTP #{res.code}", status: res.code.to_i, body: res.body)
      end

      res
    end

    def parse_json(res)
      body = res.body
      return {} if body.nil? || body.strip.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      { 'raw' => body }
    end
  end
end
