require "chart_blocks_api/version"
require 'faraday'
require 'digest/sha1'
require 'base64'
require 'json'

module ChartBlocksApi
  class Client
    URL = 'https://api.chartblocks.com'
    attr_accessor :api_token, :api_secret

    def initialize(api_token:, api_secret:)
      @api_token = api_token
      @api_secret = api_secret
    end

    def conn
      @conn ||= Faraday.new(url: URL) do |builder|
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Adapter::NetHttp
      end
    end

    def list
      body = ''
      conn.get do |req|
        req.url 'v1/chart'
        req.body = body
        req.headers['Authorization'] = authorization_header(body)
      end
    end

    def create(name:, config: nil, is_public: false)
      body = {
        name: name,
        isPublic: is_public,
        config: config
      }.to_json

      conn.post do |req|
        req.url 'v1/chart'
        req.body = body
        req.headers['Authorization'] = authorization_header(body)
      end
    end

    def get(id)
      body = ''
      conn.get do |req|
        req.url "v1/chart/#{id}"
        req.body = body
        req.headers['Authorization'] = authorization_header(body)
      end
    end

    private

    def authorization_header(body)
      encode = Base64.strict_encode64("#{API_TOKEN}:#{signature(body)}")
      "BASIC #{encode}"
    end

    def signature(body)
      key1 = Digest::SHA1.hexdigest(body)
      key2 = Digest::SHA1.hexdigest("#{key1}#{API_SECRET}")
      Base64.strict_encode64(key2)
    end
  end
end

client = ChartBlocksApi::Client.new(api_token: ENV['API_TOKEN'], api_secret: ENV['API_SECRET'])
# p client.list
# p client.create(name: 'oanda')
# p JSON.parse(client.list.body)
