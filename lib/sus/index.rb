
module Sus
	class Index
		# (path):line:line:line
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
			@contexts[identity.key] = context
		end
		
		def [] key
			@contexts[key]
		end
	end
	
	class Filter
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
		
		def call(assertions = Assertions.new)
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
