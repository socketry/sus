# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'context'

module Sus
	# The base test case class. We need to be careful about what local state is stored.
	class Base
		def initialize(assertions)
			@__assertions__ = assertions
		end
		
		def inspect
			"\#<Sus::Base for #{self.class.description.inspect}>"
		end
		
		def before
		end
		
		def after
		end
		
		def around
			self.before
			
			return yield
		ensure
			self.after
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
		
		return base
	end
end
