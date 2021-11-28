
require_relative 'assertions'

module Sus
	module Context
		attr_accessor :description
		attr_accessor :children
		
		def self.extended(base)
			base.children = Array.new
		end
		
		def print(output)
			output.print("context ", :context, self.description)
		end
		
		def call(assertions = Assertions.new)
			assertions.nested(self) do |assertions|
				self.children.each do |child|
					child.call(assertions)
				end
			end
		end
	end
	
	class Base
		def initialize(assertions)
			@assertions = assertions
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
			@assertions.assert(...)
		end
		
		def refute(...)
			@assertions.refute(...)
		end
		
		def expect(subject)
			Expect.new(subject)
		end
	end
end
