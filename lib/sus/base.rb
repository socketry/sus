# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	# Represents the base test case class. Provides core functionality for test execution including hooks for setup and teardown.
	class Base
		# Initialize a new test case instance.
		# @parameter assertions [Assertions] The assertions instance used to track test results.
		def initialize(assertions)
			@__assertions__ = assertions
		end
		
		# @returns [String] A string representation of the test case.
		def inspect
			"\#<Sus::Base for #{self.class.description.inspect}>"
		end
		
		# A hook which is called before the test is executed.
		#
		# If you override this method, you must call super.
		def before
		end
		
		# A hook which is called after the test is executed.
		#
		# If you override this method, you must call super.
		def after(error = nil)
		end
		
		# Wrap logic around the test being executed.
		#
		# Invokes the before hook, then the block, then the after hook.
		#
		# @yields {...} the block which should execute a test.
		def around(&block)
			self.before
			
			return block.call
		rescue => error
			raise
		ensure
			self.after(error)
		end
		
		# Make an assertion about a condition.
		# @parameter condition [Boolean] The condition to assert.
		# @parameter message [String | Nil] Optional message describing the assertion.
		def assert(...)
			@__assertions__.assert(...)
		end
		
		# Print an informational message during test execution.
		# @parameter message [String | Nil] The message to print, or a block that returns a message.
		def inform(...)
			@__assertions__.inform(...)
		end
	end
	
	# Create a new base test class with the given description.
	# @parameter description [String | Nil] Optional description for the test class.
	# @parameter root [String | Nil] Optional root path for the test identity.
	# @returns [Class] A new test class that extends {Base}.
	def self.base(description = nil, root: nil)
		base = Class.new(Base)
		
		base.extend(Context)
		base.identity = Identity.new(root) if root
		base.description = description
		base.set_temporary_name("#{self}[#{description}]")
		
		return base
	end
end
