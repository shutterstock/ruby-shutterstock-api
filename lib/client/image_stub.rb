module ShutterstockAPI
	class ImageStub
		attr_accessor :id, :resource_url

		def initialize(params)
			@id = params[:id] if params[:id]
			@id = params[:image_id] if params[:image_id]
			@resource_url = params[:resource_url]
		end

		def to_image
			Image.find(self.id)
		end
	end
end
