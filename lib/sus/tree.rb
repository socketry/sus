# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Sus
	# Represents a tree structure of test contexts.
	class Tree
		# Initialize a new Tree.
		# @parameter context [Object] The root context.
		def initialize(context)
			@context = context
		end
		
		# Traverse the tree, yielding each context.
		# @parameter current [Object] The current context (defaults to root).
		# @yields {|context| ...} Each context in the tree.
		# @returns [Hash] A hash representation of the tree.
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
		
		# Convert the tree to JSON.
		# @parameter options [Hash, nil] Options to pass to JSON.generate.
		# @returns [String] A JSON representation of the tree.
		def to_json(options = nil)
			traverse do |context|
				[context.identity.to_s, context.description.to_s, context.leaf?]
			end.to_json(options)
		end
	end
end
