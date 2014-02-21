module ShutterstockAPI
	class Image < Driver
		attr_reader :id, :photo_id, :resource_url, :categories, :model_release, :vector_type,
			:description, :sizes, :keywords, :web_url, :submitter_id, :submitter, :images

		def initialize(params = {})
			@hash                       = params
			@id                         = params["photo_id"].to_i
			@illustration               = json_true? params["illustration"]
			@r_rated                    = json_true? params["r_rated"]
			@enhanced_license_available = json_true? params["enhanced_license_available"]
			@is_vector                  = json_true? params["is_vector"]
			@photo_id                   = params["photo_id"].to_i
			@resource_url               = params["resource_url"]
			@categories                 = params["categories"]
			@model_release              = params["model_release"]
			@vector_type                = params["vector_type"]
			@description                = params["description"]
			@sizes                      = params["sizes"]
			@keywords                   = params["keywords"]
			@web_url                    = params["web_url"]
			@submitter_id               = params["submitter_id"].to_i
			@submitter                  = params["submitter"]
		end

		# boolean readers
		def illustration?
			@illustration
		end

		def r_rated?
			@r_rated
		end

		def enhanced_license_available?
			@enhanced_license_available
		end

		def is_vector?
			@is_vector
		end

		def self.find(opts={})
			self.new(self.get("/images/#{opts[:id]}.json", client.options).to_hash )
		end

		def find(opts={})
			self.class.find(opts)
		end

		#Image.find_similar(12345, {:page_number => 2, :sort_order => 'random'})
		def self.find_similar(id, options = {})
			opts = client.options
			opts.merge!({ :query => options})
			result = self.get( "/images/#{id}/similar.json", opts )
			Images.new(result.to_hash)
		end

		#Image.search(client, 'dogs', {:page_number => 2, :sort_order => 'random'})
		def self.search(search, options = {})
			search_params = {}
			if search.kind_of? String
				search_params[:searchterm] = search
			else
				search_params = search
			end
			search_params.merge!(options)
			opts = client.options
			opts.merge!({ :query => search_params })

			Images.new( self.get( "/images/search.json", opts).to_hash )
		end

		def find_similar(options = {})
			@images = self.class.find_similar(self.id, options)
		end

	end
end
