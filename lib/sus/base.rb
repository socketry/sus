
require_relative 'context'
require_relative 'loader'

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
		
		def refute(...)
			@__assertions__.refute(...)
		end
	end
	
	def self.base(description = nil)
		base = Class.new(Base)
		
		base.extend(Context)
		base.description = description
				
		return base
	end
end
