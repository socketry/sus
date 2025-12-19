# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	# Represents a test context that behaves like a shared context.
	module ItBehavesLike
		extend Context
		
		# @attribute [Shared] The shared context being used.
		attr_accessor :shared
		
		# Build a new ItBehavesLike context.
		# @parameter parent [Class] The parent context class.
		# @parameter shared [Shared] The shared context to use.
		# @parameter arguments [Array | Nil] Optional arguments to pass to the shared context.
		# @parameter unique [Boolean] Whether the identity should be unique.
		# @yields {...} Optional block to execute before the shared context.
		# @returns [Class] A new test class that behaves like the shared context.
		def self.build(parent, shared, arguments = nil, unique: false, &block)
			base = Class.new(parent)
			base.singleton_class.prepend(ItBehavesLike)
			base.children = Hash.new
			base.description = shared.name
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.set_temporary_name("#{self}[#{base.description}]")
			
			# User provided block is evaluated first, so that it can provide default behaviour for the shared context:
			if block_given?
				base.class_exec(*arguments, &block)
			end
			
			base.class_exec(*arguments, &shared.block)
			return base
		end
		
		# Print a representation of this context.
		# @parameter output [Output] The output target.
		def print(output)
			self.superclass.print(output)
			output.write(" it behaves like ", :describe, self.description, :reset)
		end
	end
	
	module Context
		# Define a test context that behaves like a shared context.
		# @parameter shared [Shared] The shared context to use.
		# @parameter arguments [Array] Optional arguments to pass to the shared context.
		# @parameter options [Hash] Additional options.
		# @yields {...} Optional block to execute before the shared context.
		def it_behaves_like(shared, *arguments, **options, &block)
			add ItBehavesLike.build(self, shared, arguments, **options, &block)
		end
	end
end
