module ShutterstockAPI
	class Lightbox < Driver
		attr_reader :id, :name, :images, :confirmed, :resource_url, :hash

		def initialize(params={})
			@hash         = params # backwards compatability for method missing
			@id           = params["lightbox_id"].to_i
			@name         = params["lightbox_name"]
			@images       = Images.new(params["images"])
			@confirmed    = json_true? params["confirmed"]
			@resource_url = params["resource_url"]
		end

		def confirmed?
			@confirmed
		end

		def self.find(opts={})
			resp  = self.get("/lightboxes/#{opts[:id]}/extended.json", client.options)
			if(resp.code == 200)
				self.new(resp.to_hash)
			else
				raise RuntimeError, "Something went wrong: #{resp.body}"
			end
		end

		def find(opts={})
			self.class.find(opts)
		end

		def self.create(opts={})
			req_opts = {}
			req_opts.merge!(client.options)

			raise ArgumentError, "username not provided" unless opts[:username]
			raise ArgumentError, "lightbox name not provided" unless opts[:lightbox_name]

			req_opts.merge!(body: { username: opts[:username], lightbox_name: opts[:lightbox_name] })

			resp = self.post("/customers/#{opts[:username]}/lightboxes.json", req_opts)

			if (resp.code == 201)
				resp_hash = resp.to_hash
				resp_hash.merge!("lightbox_name" => opts[:lightbox_name])
				self.new(resp_hash)
			elsif(resp.code == 409)
				raise RuntimeError, "Something went wrong: #{resp.body}"
			else
				raise RuntimeError, "Something went wrong: #{resp.code} #{response.message}"
			end
		end

		def self.update(opts={})
			req_opts = {}
			req_opts.merge!(client.options)

			raise ArgumentError, "lightbox name not provided" unless opts[:lightbox_name]

			req_opts.merge!(body: { username: opts[:username], lightbox_name: opts[:lightbox_name] })
			resp = self.post("/lightboxes/#{opts[:id]}.json", req_opts)

			raise RuntimeError, "Something went wrong: #{resp.body}" unless (resp.code == 204)
		end

		def self.destroy(opts={})
			resp = self.delete("/lightboxes/#{opts[:id]}.json", client.options)
			raise RuntimeError, "Something went wrong: #{resp.message}" unless (resp.code == 204)
		end

		# Lightbox.add_image({lightbox_id: 1234556, image_id: 98765432})
		def self.add_image(opts={})
			req_opts = {}
			req_opts.merge!(client.options)

			raise ArgumentError, "lightbox id not provided" unless opts[:lightbox_id]
			raise ArgumentError, "image id not  provided" unless opts[:image_id]
			resp = self.put("/lightboxes/#{opts[:lightbox_id]}/images/#{opts[:image_id]}.json?username=#{client.config.username}", req_opts)
			raise RuntimeError, "Something went wrong: #{resp.message}" unless (resp.code == 200)
		end

		def add_image(opts={})
			self.class.add_image({lightbox_id: self.id, image_id: opts[:image_id]})
		end

		# Lightbox.remove_image({lightbox_id: 1234556, image_id: 98765432})
		def self.remove_image(opts={})
			req_opts = {}
			req_opts.merge!(client.options)

			raise ArgumentError, "lightbox id not provided" unless opts[:lightbox_id]
			raise ArgumentError, "image id not  provided" unless opts[:image_id]
			resp = self.delete("/lightboxes/#{opts[:lightbox_id]}/images/#{opts[:image_id]}.json?username=#{client.config.username}", req_opts)
			raise RuntimeError, "Something went wrong: #{resp.message}" unless (resp.code == 200)
		end

		def remove_image(opts={})
			self.class.remove_image({lightbox_id: self.id, image_id: opts[:image_id]})
		end
	end
end
