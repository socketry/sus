
module Sus
	class Identity
		def self.nested(parent, name, location = nil)
			location ||= caller_locations(3...4).first
			
			self.new(location.path, name, location.lineno, parent)
		end
		
		def initialize(path, name = nil, line = nil, parent = nil)
			@path = path
			@name = name
			@line = line
			@parent = parent
		end
		
		attr :path
		attr :name
		attr :line
		
		def to_s
			if @line
				"#{@path}:#{@line}"
			else
				@path
			end
		end
		
		def match?(other)
			if path = other.path
				return false unless path === @path
			end
			
			if name = other.name
				return false unless name === @name
			end
			
			if line = other.line
				return false unless line === @line
			end
		end
		
		def each(&block)
			@parent&.each(&block)
			
			yield self
		end
	end
end