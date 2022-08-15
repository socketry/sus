module Sus
	class Clock
		include Comparable
		
		def initialize(duration = 0.0)
			@duration = duration
		end
		
		attr :duration
		
		def <=>(other)
			@duration <=> other.to_f
		end
		
		def to_f
			@duration
		end
		
		def to_s
			if @duration < 0.001
				"#{(@duration * 1_000_000).round(1)}µs"
			elsif @duration < 1.0
				"#{(@duration * 1_000).round(1)}ms"
			else
				"#{@duration.round(1)}s"
			end
		end
		
		def start!
			@start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
		end
		
		def stop!
			if @start_time
				@duration += Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time
				@start_time = nil
			end
		end
	end
end
