
module Sus
	class Filter
		class Index
			def initialize
				@contexts = {}
			end
			
			attr :contexts
			
			def add(parent)
				parent.children&.each do |identity, child|
					insert(identity, child)
					add(child)
				end
			end
			
			def insert(identity, context)
				key = identity.key
				
				if existing_context = @contexts[key]
					raise KeyError, "Assigning context to existing key: #{key.inspect}!"
				else
					@contexts[key] = context
				end
			end
			
			def [] key
				@contexts[key]
			end
		end
		
		def initialize(registry: Registry.new)
			@registry = registry
			@index = nil
			@keys = Array.new
		end
		
		def load(target)
			path, filter = target.split(':', 2)
			
			@registry.load(path)
			
			if filter
				@keys << target
			end
		end
		
		def each(&block)
			if @keys.any?
				@index = Index.new
				@index.add(@registry)
				
				@keys.each do |key|
					if target = @index[key]
						yield target
					end
				end
			else
				@registry.each(&block)
			end
		end
		
		def call(assertions = Assertions.default)
			if @keys.any?
				@index = Index.new
				@index.add(@registry)
				
				@keys.each do |key|
					@index[key]&.call(assertions)
				end
			else
				@registry.call(assertions)
			end
			
			return assertions
		end
	end
end
