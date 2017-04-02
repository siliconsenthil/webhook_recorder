# WebhookRecorder

When you build a feature that makes calls to webhooks of subscribers, this library helps to test that behaviour.

This runs a simple WEBrick server, makes it accessible via [ngrok](https://ngrok.com) and records the results. You can assert on the recorded requests to ensure the code you built made calls to registered webhooks.

## Dependency

This uses [ngrok](https://ngrok.com) to publish URL that's accessible via internet.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'webhook_recorder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webhook_recorder

## Usage

* If you have ngrok account, set env. var `NGROK_AUTH_TOKEN` before running

```ruby
it 'should respond as defined as response_config' do
  response_config = { '/hello' => { code: 200, body: 'Expected result' } }
  WebhookRecorder::Server.open(@port, response_config) do |server|
    #These URLs are accessible from internet
    p server.http_url
    p server.https_url

    # Register the webhook with any of the above URLs
    # Make call to the code that invokes webhooks
    # For e.g. if it made call to /hello with query params as q=1 and JSON body as {some: 1, other: 2}, you can assert like below.

    req1 = server.recorded_reqs.first
    expect(req1[:request_path]).to eq('/hello')
    expect(req1[:query_string]).to include('q=1')
    expect(JSON.parse(req1[:request_body]).symbolize_keys).to eq({some: 1, other: 2})
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/siliconsenthil]/webhook_recorder.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
