# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

module Sus
	class Clock
		include Comparable
		
		def self.start!
			self.new.tap(&:start!)
		end
		
		def initialize(duration = 0.0)
			@duration = duration
		end
		
		def duration
			if @start_time
				now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
				@duration += now - @start_time
				@start_time = now
			end
			
			return @duration
		end
		
		def <=>(other)
			duration <=> other.to_f
		end
		
		def to_f
			duration
		end
		
		def ms
			duration * 1000.0
		end
		
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
		
		def reset!(duration = 0.0)
			@duration = duration
		end
		
		def start!
			@start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
		end
		
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
