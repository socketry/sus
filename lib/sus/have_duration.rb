
module Sus
	class HaveDuration
		def initialize(predicate)
			@predicate = predicate
		end
		
		def print(output)
			output.write("have duration ")
			@predicate.print(output)
		end
		
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				duration = measure(subject)
				
				@predicate.call(assertions, duration)
			end
		end
		
		class << self
			def < duration
				new(Be < duration)
			end
			
			def <= duration
				new(Be <= duration)
			end
			
			def > duration
				new(Be > duration)
			end
			
			def >= duration
				new(Be >= duration)
			end
		end
		
		private
		
		def measure(subject)
			start_time = now
			
			subject.call
			
			return now - start_time
		end
		
		def now
			::Process.clock_gettime(Process::CLOCK_MONOTONIC)
		end
	end
	
	class Base
		def have_duration(*arguments)
			if arguments.any?
				HaveDuration.new(be_within(*arguments))
			else
				HaveDuration
			end
		end
	end
end
