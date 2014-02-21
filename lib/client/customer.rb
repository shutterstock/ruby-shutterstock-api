module ShutterstockAPI
	class Customer < Driver
		attr_reader :username, :account_id, :sales_rep_info

		def initialize(params={})
			@hash           = params # used to support
			@username       = params["username"]
			@account_id     = params["account_id"].to_i
			@sales_rep_info = params["sales_rep_info"]
		end

		def self.find(opts={})
			options = client.options
			hash = self.get("/customers/#{opts[:username]}.json", options).to_hash
			hash["username"] = opts[:username]

			self.new(hash)
		end

		def find(opts={})
			self.class.find(opts)
		end

		def lightboxes
			resp = self.class.get("/customers/#{@username}/lightboxes/extended.json", client.options)
			JSON.parse(resp.body).map { |hash| Lightbox.new(hash) }
		end

		def downloads
			self.class.get("/customers/#{@username}/images/downloads.json", client.options).to_hash
		end

	end
end
