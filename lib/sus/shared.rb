# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	# Represents a shared test context that can be reused across multiple test files.
	module Shared
		# @attribute [String] The name of the shared context.
		attr_accessor :name
		
		# @attribute [Proc] The block containing the shared test code.
		attr_accessor :block
		
		# Build a new Shared context.
		# @parameter name [String] The name of the shared context.
		# @parameter block [Proc] The block containing the shared test code.
		# @returns [Module] A new Shared module.
		def self.build(name, block)
			base = Module.new
			base.extend(Shared)
			base.name = name
			base.block = block
			
			return base
		end
		
		# Called when this module is included in a test class.
		# @parameter base [Class] The class including this module.
		def included(base)
			base.class_exec(&self.block)
		end
		
		# Called when this module is prepended to a test class.
		# @parameter base [Class] The class prepending this module.
		def prepended(base)
			base.class_exec(&self.block)
		end
	end
	
	# Create a new shared test context.
	# @parameter name [String] The name of the shared context.
	# @yields {...} The block containing the shared test code.
	# @returns [Shared] A new Shared module.
	def self.Shared(name, &block)
		Shared.build(name, block)
	end
end
