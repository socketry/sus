# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

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
				[context.identity.to_s, context.description.to_s, context.leaf?]
			end.to_json(options)
		end
	end
end
