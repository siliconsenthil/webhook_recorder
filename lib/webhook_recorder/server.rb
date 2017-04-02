require 'webhook_recorder/version'
require 'rack'
require 'webrick'
require 'ngrok/tunnel'
require 'active_support/core_ext/hash'

module WebhookRecorder
  class Server
    attr_accessor :recorded_reqs, :http_url, :https_url, :response_config, :port, :log_verbose

    def initialize(port, response_config, log_verbose = false)
      self.port = port
      self.response_config = response_config
      self.recorded_reqs = []
      self.log_verbose = log_verbose
      @started = false
    end

    def self.open(port, response_config, log_verbose=false)
      server = new(port, response_config, log_verbose)
      server.start
      server.wait
      Ngrok::Tunnel.start(port: port)
      server.http_url = Ngrok::Tunnel.ngrok_url
      server.https_url = Ngrok::Tunnel.ngrok_url_https
      yield server
    ensure
      server.recorded_reqs.clear
      server.stop
      Ngrok::Tunnel.stop
    end

    def start
      Thread.new do
        options = {
          Port: @port,
          Logger: WEBrick::Log.new(self.log_verbose ? STDOUT : "/dev/null"),
          AccessLog: [],
          DoNotReverseLookup: true,
          StartCallback: -> { @started = true }
        }
        Rack::Handler::WEBrick.run(self, options) { |s| @server = s }
      end
    end

    def wait
      Timeout.timeout(10) { sleep 0.1 until @started }
    end

    def call(env)
      path = env['PATH_INFO']
      request = Rack::Request.new(env)
      recorded_reqs << env.merge(request_body: request.body.string).deep_transform_keys(&:downcase).with_indifferent_access
      if response_config[path]
        res = response_config[path]
        [res[:code], res[:headers] || {}, [res[:body] || "Missing body in response_config"]]
      else
        warn "WebhookRecorder::Server: Missing response_config for path #{path}"
        [404, {}, ["WebhookRecorder::Server: Missing response_config for path #{path}"]]
      end
    end

    def stop
      @server.shutdown if @server
    end
  end
end