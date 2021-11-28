
require_relative 'context'

require_relative 'describe'
require_relative 'with'
require_relative 'it'
require_relative 'let'

module Sus
	class Registry
		def initialize
			@base = Class.new(Base)
			@base.extend(Context)
			@base.description = self.class.name
		end
		
		attr :base
		
		def load(path)
			@base.describe(path) do
				self.class_eval(File.read(path), path)
			end
		end
		
		def call
			start_time = self.time
			
			assertions = Assertions.new(verbose: true)
			
			@base.call(assertions)
			
			duration = self.time - start_time
			
			pp assertions_per_second: (assertions.count / duration)
		end
		
		private
		
		def time
			::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
		end
	end
end
