require 'webmock'
require 'vcr'
require 'rspec'

require 'shutterstock-client'
include ShutterstockAPI

DEFAULTS = {
  SSTK_API_USERNAME: 'basicauthusername',
  SSTK_API_KEY: 'basicauthapikey',
  SSTK_BASE_API_URI: 'http://api.shutterstock.com',
  SSTK_AUTH_TOKEN: 'basicauthtoken',
  SSTK_USERNAME: 'testuser',
  SSTK_PASSWORD: 'testpassword'
}

def sensitive_data(c, env_key)
  c.filter_sensitive_data("<#{env_key}>") do
    ENV[env_key.to_s] || DEFAULTS[env_key]
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  sensitive_data(c, :SSTK_API_USERNAME)
  sensitive_data(c, :SSTK_API_KEY)
  sensitive_data(c, :SSTK_USERNAME)
  sensitive_data(c, :SSTK_PASSWORD)
end

if ENV['VCR_OFF']
  WebMock.allow_net_connect!
  VCR.turn_off!(ignore_cassettes: true)
end

uri_without_auth_token = VCR.request_matchers.uri_without_param(:auth_token)

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  # Add VCR to all tests
  config.around(:each) do |example|
    options = example.metadata[:vcr] || {}
    options[:match_requests_on] = [:method, uri_without_auth_token]
    if options[:record] == :skip
      VCR.turned_off(&example)
    else
      name = example.metadata[:full_description]
        .split(/\s+/, 2).join('/')
        .gsub(/[^\w\/]+/, '_')
      VCR.use_cassette(name, options, &example)
    end
  end
end

def client
	Client.instance.configure do |config|
		config.api_username = ENV['SSTK_API_USERNAME'] || "basicauthusername"
		config.api_key = ENV['SSTK_API_KEY'] || "basicauthapikey"
		config.username = ENV['SSTK_USERNAME'] || "testuser"
		config.password = ENV['SSTK_PASSWORD'] || "testpassword"
	end
	Client.instance
end

def client_double
  double(
    api_username: api_username,
    api_key: api_key,
    api_url: base_api_uri,
    username: username,
    password: password,
    auth_token: auth_token,
    options: auth_options
  )
end

def mocked_auth
  Client.any_instance.stub(:get_auth_token)
  client
  client.stub(:auth_token).and_return(auth_token)
  client.stub(:options).and_return(auth_options)
end

private

def auth_options(opts = {})
  {
    base_uri: base_api_uri,
    basic_auth: {
      username: api_username,
      password: api_key
    },
    default_params: {
      auth_token: auth_token
    }
  }.merge(opts)
end

def env_or_default(key)
  ENV[key.to_s] || DEFAULTS[key]
end

def api_username
  env_or_default(:SSTK_API_USERNAME)
end

def api_key
  env_or_default(:SSTK_API_KEY)
end

def base_api_uri
  env_or_default(:SSTK_BASE_API_URI)
end

def auth_token
  env_or_default(:SSTK_AUTH_TOKEN)
end

def username
  env_or_default(:SSTK_USERNAME)
end

def password
  env_or_default(:SSTK_PASSWORD)
end
