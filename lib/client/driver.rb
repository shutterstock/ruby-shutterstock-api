module ShutterstockAPI
	class Driver

		include HTTParty

		def method_missing(method, *args, &block)
			return @hash[method.to_s] if(@hash[method.to_s])
			if(method.match(/\?$/))
				is_method = method.to_s.gsub(/\?$/, "")
				if defined? @hash[is_method]
					return @hash[is_method].to_i == 1 ? true : false
				end
			else
				super()
			end
		end

		def respond_to(method)
			return true if @hash[method.to_s]
			super()
		end

		def methods
			methods = super()
			[methods, @hash.keys.map{ |k| k.to_sym} ].flatten
		end

		TRUTHY_JSON_VALUES = [ "1", 1, true, "true"]
		def json_true?(thing)
			TRUTHY_JSON_VALUES.include? thing
		end

		def client
			Client.instance
		end

		def self.client
			Client.instance
		end
	end
end
