module ShutterstockAPI
	class Images < Array
		attr_reader :raw_data, :page, :total_count, :sort_method, :search_src_id
		def initialize(raw_data)
			@raw_data = raw_data

			if raw_data.kind_of? Hash
				super(@raw_data["results"].map{ |image| Image.new(image) }) 

				@total_count   = raw_data["count"].to_i
				@page          = raw_data["page"].to_i
				@sort_method   = raw_data["sort_method"]
				@search_src_id = raw_data["searchSrcID"]
			elsif raw_data.kind_of? Array
				super( @raw_data.map{ |image| Image.new(image) } )
			end

			self
		end
	end
end
