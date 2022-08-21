
require_relative 'base'

require_relative 'file'
require_relative 'describe'
require_relative 'with'

require_relative 'it'

require_relative 'shared'
require_relative 'it_behaves_like'
require_relative 'include_context'

require_relative 'let'

module Sus
	class Registry
		# Create a top level scope with self as the instance:
		def initialize(base = Sus.base(self))
			@base = base
		end
		
		attr :base
		
		def print(output)
			output.write "Test Registry"
		end
		
		def load(path)
			@base.file(path)
		end
		
		def call(assertions = Assertions.default)
			@base.call(assertions)
			
			return assertions
		end
		
		def each(...)
			@base.each(...)
		end
		
		def children
			@base.children
		end
	end
end
