module Sus
	class Tree
		def initialize(context)
			@context = context
		end
		
		def traverse(current = @context, &block)
			node = {}
			
			node[:self] = yield(current)
			
			if children = current.children # and children.any?
				node[:children] = children.values.map do |context|
					self.traverse(context, &block)
				end
			end
			
			return node
		end
		
		def to_json(options = nil)
			traverse do |context|
				[context.identity, context.description, context.leaf?]
			end.to_json(options)
		end
	end
end
