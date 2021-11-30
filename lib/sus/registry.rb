
require_relative 'context'

require_relative 'describe'
require_relative 'with'
require_relative 'it'
require_relative 'let'

module Sus
	class Registry
		# Create a top level scope with self as the base instance:
		CLASS_BINDING = TOPLEVEL_BINDING.eval('->(base){base.class_eval{binding}}')
		
		def initialize
			@base = Class.new(Base)
			@base.extend(Context)
			@base.description = "top level"
		end
		
		attr :base
		
		def load(path)
			@base.describe(path, identity: Identity.new(path)) do
				eval(File.read(path), CLASS_BINDING.call(self), path)
			end
		end
		
		def call
			assertions = Assertions.new(verbose: true)
			@base.call(assertions)
		end
		
		def each(...)
			@base.each(...)
		end
		
		private
		
		def time
			::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
		end
	end
end
