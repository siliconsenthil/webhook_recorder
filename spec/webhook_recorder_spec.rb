require 'spec_helper'

RSpec.describe WebhookRecorder do
  before do
    @port = 4545
  end

  it 'has a version number' do
    expect(WebhookRecorder::VERSION).not_to be nil
  end

  context 'open' do
    it 'should respond as defined as response_config' do
      response_config = { '/hello' => { code: 200, body: 'Expected result' } }
      WebhookRecorder::Server.open(@port, response_config) do |server|
        expect(server.http_url).not_to be_nil
        expect(server.https_url).not_to be_nil

        res = RestClient.post "#{server.http_url}/hello?q=1", {some: 1, other: 2}.to_json

        expect(res.code).to eq(200)
        expect(res.body).to eq('Expected result')
        expect(server.recorded_reqs.size).to eq(1)
        req1 = server.recorded_reqs.first
        expect(req1[:request_path]).to eq('/hello')
        expect(req1[:query_string]).to include('q=1')
        expect(req1[:http_user_agent]).to include('rest-client')
        expect(JSON.parse(req1[:request_body]).symbolize_keys).to eq({some: 1, other: 2})
      end
    end

    it 'should respond with 404 if not configured' do
      WebhookRecorder::Server.open(@port, {}) do |server|
        expect(server.http_url).not_to be_nil
        expect(server.https_url).not_to be_nil

        expect do
          res = RestClient.get "#{server.https_url}/hello"
        end.to raise_error(RestClient::NotFound)
      end
    end
  end
end
