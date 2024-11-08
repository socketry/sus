# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	# The base test case class. We need to be careful about what local state is stored.
	class Base
		def initialize(assertions)
			@__assertions__ = assertions
		end
		
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
		
		def assert(...)
			@__assertions__.assert(...)
		end
		
		def inform(...)
			@__assertions__.inform(...)
		end
	end
	
	def self.base(description = nil, root: nil)
		base = Class.new(Base)
		
		base.extend(Context)
		base.identity = Identity.new(root) if root
		base.description = description
		base.set_temporary_name("#{self}[#{description}]")
		
		return base
	end
end
