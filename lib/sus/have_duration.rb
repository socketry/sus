# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	# Represents a predicate that measures the duration of a block execution.
	class HaveDuration
		# Initialize a new HaveDuration predicate.
		# @parameter predicate [Object] The predicate to apply to the measured duration.
		def initialize(predicate)
			@predicate = predicate
		end
		
		# Print a representation of this predicate.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("have duration ")
			@predicate.print(output)
		end
		
		# Evaluate this predicate against a subject (block).
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Proc] The block to measure.
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				Expect.new(assertions, measure(subject)).to(@predicate)
			end
		end
		
		private
		
		# Measure the duration of executing a block.
		# @parameter subject [Proc] The block to measure.
		# @returns [Float] The duration in seconds.
		def measure(subject)
			start_time = now
			
			subject.call
			
			return now - start_time
		end
		
		# Get the current monotonic time.
		# @returns [Float] The current time in seconds.
		def now
			::Process.clock_gettime(Process::CLOCK_MONOTONIC)
		end
	end
	
	class Base
		# Create a predicate that measures the duration of a block execution.
		# @parameter predicate [Object] The predicate to apply to the measured duration.
		# @returns [HaveDuration] A new HaveDuration predicate.
		def have_duration(...)
			HaveDuration.new(...)
		end
	end
end
