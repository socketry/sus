# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

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
				Expect.new(assertions, measure(subject)).to(@predicate)
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
		def have_duration(...)
			HaveDuration.new(...)
		end
	end
end
