
require_relative 'base'

require_relative 'describe'
require_relative 'with'

require_relative 'it'
require_relative 'it_behaves_like'
require_relative 'shared'

require_relative 'let'

# This has to be done at the top level. It allows us to define constants within the given class while still retaining top-level constant resolution.
TOPLEVEL_CLASS_EVAL = ->(klass, path){klass.class_eval(File.read(path), path)}

module Sus
	class Registry
		# Create a top level scope with self as the instance:
		def initialize(base = Sus.base("test registry"))
			@base = base
		end
		
		attr :base
		
		def load(path)
			@base.describe(path, identity: Identity.new(path)) do
				TOPLEVEL_CLASS_EVAL.call(self, path)
			end
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
