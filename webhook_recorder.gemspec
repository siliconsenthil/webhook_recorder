# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webhook_recorder/version'

Gem::Specification.new do |spec|
  spec.name          = 'webhook_recorder'
  spec.version       = WebhookRecorder::VERSION
  spec.authors       = ['Senthil V S']
  spec.email         = ['vss123@gmail.com']

  spec.summary       = 'Simple HTTP server helps to test behaviour that calls webhooks'
  spec.description   = 'It runs a HTTP server, exposes in internet via ngrok, and records the requests'
  spec.homepage      = 'https://github.com/siliconsenthil/webhook_recorder'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  # spec.bindir        = 'exe'
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '~>5.0.2'
  spec.add_runtime_dependency 'webrick', '~>1.3.1'
  spec.add_runtime_dependency 'ngrok-tunnel', '~>2.1.0'
  spec.add_runtime_dependency 'rack', '~>2.0.1'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rest-client', '~> 2.0.1'
end
