
require_relative 'context'

module Sus
	class Base
		def initialize(assertions)
			@assertions = assertions
			@mocks = nil
		end
		
		def before
		end
		
		def after
			@mocks&.each(&:clear)
		end
		
		def around
			self.before
			
			return yield
		ensure
			self.after
		end
		
		def assert(...)
			@assertions.assert(...)
		end
		
		def refute(...)
			@assertions.refute(...)
		end
		
		def expect(subject)
			Expect.new(subject)
		end
		
		def mock(target)
			instance = Mock.new(target)
			
			(@mocks ||= Array.new) << instance
			
			return instance
		end
	end
	
	def self.base(description = "base")
		base = Class.new(Base)
		base.extend(Context)
		base.description = description
		
		return base
	end
end
