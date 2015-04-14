require 'httparty'
require 'active_support/all'
require 'singleton'

module ShutterstockAPI
  require 'client/driver'
  require 'client/configuration'
  require 'client/customer'
  require 'client/images'
  require 'client/image'
  require 'client/lightbox'

	class Client
		include HTTParty
		include Singleton

		# @return [Configuration] Config instance
		attr_reader :config

		# Request options
		attr_accessor :options

		# Creates a new {Client} instance and yields {#config}.
		# Requires a block to be given.
		def configure
			raise ArgumentError, "block not given" unless block_given?

			@config = Configuration.new
			yield config

			@config.api_url ||= "http://api.shutterstock.com"
			raise ArgumentError, "API Username not provided" if config.api_username.nil?
			raise ArgumentError, "API Key not provided" if config.api_key.nil?

			@options = {
				base_uri: config.api_url,
				basic_auth: {
					username: config.api_username,
					password: config.api_key
				}
			}

			if (config.username && config.password)
				get_auth_token
			end

			@options.delete_if{|k, v| k == :body}

			@options.merge!({
				default_params: {
					auth_token: config.auth_token
				}
			})
		end

		def configured?
			! config.nil?
		end

		def get_auth_token
			options=@options
			options[:body] = { :username => config.username, :password => config.password}
			response = self.class.post( "#{config.api_url}/auth/customer.json", options )

			if response.code == 200
				config.auth_token = response["auth_token"]
			else
				raise RuntimeError, "Something went wrong: #{response.code} #{response.message}"
			end
			return config.auth_token
		end

		def method_missing(method, *args, &block)
			method = method.to_s
			options = args.last.is_a?(Hash) ? args.pop : {}

			klass = self.class.modulize_string(method.singularize)

			if ShutterstockAPI.const_defined?(klass)
				klass_as_const = ShutterstockAPI.const_get(klass)
				klass_as_const.new(options)
			else
				super
			end
		end

		def customers
			Customer.new({"username" => config.username})
		end

		# From https://github.com/rubyworks/facets/blob/master/lib/core/facets/string/modulize.rb
		def self.modulize_string(string)
			#gsub('__','/').  # why was this ever here?
			string.gsub(/__(.?)/){ "::#{$1.upcase}" }.
				gsub(/\/(.?)/){ "::#{$1.upcase}" }.
				gsub(/(?:_+|-+)([a-z])/){ $1.upcase }.
				gsub(/(\A|\s)([a-z])/){ $1 + $2.upcase }
		end

		# From https://github.com/rubyworks/facets/blob/master/lib/core/facets/string/snakecase.rb
		def self.snakecase_string(string)
			#gsub(/::/, '/').
			string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
				gsub(/([a-z\d])([A-Z])/,'\1_\2').
				tr('-', '_').
				gsub(/\s/, '_').
				gsub(/__+/, '_').
				downcase
		end
	end
end
