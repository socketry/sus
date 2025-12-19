# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	# Represents a test context with specific conditions or variables.
	module With
		extend Context
		
		# @attribute [String] The subject description of this context.
		attr_accessor :subject
		
		# @attribute [Hash] The variables available in this context.
		attr_accessor :variables
		
		# Build a new with block class.
		# @parameter parent [Class] The parent context class.
		# @parameter subject [String] The subject description.
		# @parameter variables [Hash] Variables to make available in the context.
		# @parameter unique [Boolean] Whether the identity should be unique.
		# @yields {...} Optional block containing nested tests.
		# @returns [Class] A new with block class.
		def self.build(parent, subject, variables, unique: true, &block)
			base = Class.new(parent)
			base.singleton_class.prepend(With)
			base.children = Hash.new
			base.subject = subject
			base.description = subject
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.set_temporary_name("#{self}[#{base.description}]")
			
			base.variables = variables
			
			base.define_method(:description, ->{subject})
			
			variables.each do |key, value|
				base.define_method(key, ->{value})
			end
			
			if block_given?
				base.class_exec(&block)
			end
			
			return base
		end
		
		# Print a representation of this with block.
		# @parameter output [Output] The output target.
		def print(output)
			self.superclass.print(output)
			
			output.write(
				" with ", :with, self.description, :reset,
				# " ", :variables, self.variables.inspect
			)
		end
	end
	
	module Context
		# Define a new test context with specific conditions or variables.
		# @parameter subject [String | Nil] Optional subject description. If nil, uses variables.inspect.
		# @parameter unique [Boolean] Whether the identity should be unique.
		# @parameter variables [Hash] Variables to make available in the context.
		# @yields {...} Optional block containing nested tests.
		def with(subject = nil, unique: true, **variables, &block)
			subject ||= variables.inspect
			
			add With.build(self, subject, variables, unique: unique, &block)
		end
	end
end
