# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	# Represents a test group that describes a subject (class, module, or feature).
	module Describe
		extend Context
		
		# @attribute [Object] The subject being described.
		attr_accessor :subject
		
		# Build a new describe block class.
		# @parameter parent [Class] The parent context class.
		# @parameter subject [Object] The subject to describe.
		# @parameter unique [Boolean] Whether the identity should be unique.
		# @yields {...} Optional block containing nested tests.
		# @returns [Class] A new describe block class.
		def self.build(parent, subject, unique: true, &block)
			base = Class.new(parent)
			base.singleton_class.prepend(Describe)
			base.children = Hash.new
			base.subject = subject
			base.description = subject.to_s
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.set_temporary_name("#{self}[#{base.description}]")
			
			base.define_method(:subject, ->{subject})
			
			if block_given?
				base.class_exec(&block)
			end
			
			return base
		end
		
		# Print a representation of this describe block.
		# @parameter output [Output] The output target.
		def print(output)
			output.write(
				"describe ", :describe, self.description, :reset,
				# " ", self.identity.to_s
			)
		end
	end
	
	module Context
		# Define a new test group describing a subject.
		# @parameter subject [Object] The subject to describe (class, module, or feature).
		# @parameter options [Hash] Additional options.
		# @yields {...} Optional block containing nested tests.
		def describe(subject, **options, &block)
			add Describe.build(self, subject, **options, &block)
		end
	end
end
