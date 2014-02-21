module ShutterstockAPI
	class Configuration
		# @return [String] The basic auth username.
		attr_accessor :api_username

		# @return [String] The basic auth password.
		attr_accessor :api_key

		# @return [String] The basic auth token.
		attr_accessor :auth_token

		# @return [String] The API url.
		attr_accessor :api_url

		# @return [String] Customer's username.
		attr_accessor :username

		# @return [String] Customer's password.
		attr_accessor :password

		def initialize
			@client_options = {}
		end

	end
end
