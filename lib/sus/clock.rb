# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

module Sus
	# Represents a clock for measuring elapsed time during test execution.
	class Clock
		include Comparable
		
		# Create a new clock and start it immediately.
		# @returns [Clock] A new started clock.
		def self.start!
			self.new.tap(&:start!)
		end
		
		# Initialize a new clock.
		# @parameter duration [Float] Initial duration in seconds.
		def initialize(duration = 0.0)
			@duration = duration
		end
		
		# Get the current elapsed duration.
		# @returns [Float] The elapsed duration in seconds.
		def duration
			if @start_time
				now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
				@duration += now - @start_time
				@start_time = now
			end
			
			return @duration
		end
		
		# Compare this clock's duration with another value.
		# @parameter other [Numeric] The value to compare against.
		# @returns [Integer] -1, 0, or 1 depending on comparison result.
		def <=>(other)
			duration <=> other.to_f
		end
		
		# Convert the duration to a float.
		# @returns [Float] The duration in seconds.
		def to_f
			duration
		end
		
		# Get the duration in milliseconds.
		# @returns [Float] The duration in milliseconds.
		def ms
			duration * 1000.0
		end
		
		# Get a human-readable string representation of the duration.
		# @returns [String] A formatted duration string (e.g., "1.5ms", "2.3s").
		def to_s
			duration = self.duration
			
			if duration < 0.001
				"#{(duration * 1_000_000).round(1)}µs"
			elsif duration < 1.0
				"#{(duration * 1_000).round(1)}ms"
			else
				"#{duration.round(1)}s"
			end
		end
		
		# Reset the clock to a specific duration.
		# @parameter duration [Float] The duration to reset to.
		def reset!(duration = 0.0)
			@duration = duration
		end
		
		# Start the clock.
		def start!
			@start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
		end
		
		# Stop the clock and return the final duration.
		# @returns [Float] The final duration in seconds.
		def stop!
			if @start_time
				now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
				@duration += now - @start_time
				@start_time = nil
			end
			
			return duration
		end
	end
end
