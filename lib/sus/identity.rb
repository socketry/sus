
module Sus
	class Identity
		def self.nested(parent, name, location = nil, **options)
			location ||= caller_locations(3...4).first
			
			self.new(location.path, name, location.lineno, parent, **options)
		end
		
		def initialize(path, name = nil, line = nil, parent = nil, unique: true)
			@path = path
			@name = name
			@line = line
			@parent = parent
			@unique = unique
			
			@key = nil
		end
		
		attr :path
		attr :name
		attr :line
		attr :parent
		attr :unique
		
		def to_s
			self.key
		end
		
		def inspect
			"\#<#{self.class} #{self.to_s}>"
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
		
		def key
			unless @key
				key = Array.new
				
				append_unique_key(key, false)
				
				@key = key.join(':')
			end
			
			return @key
		end
		
		protected
		
		def append_unique_key(key, unique = @unique)
			if @parent
				@parent.append_unique_key(key)
			else
				key << @path
			end
			
			if @line
				key << @line unless unique
			end
		end
	end
end
