# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "bar"
require_relative "status"
require_relative "lines"

module Sus
	module Output
		class Progress
			def self.now
				::Process.clock_gettime(Process::CLOCK_MONOTONIC)
			end
			
			def initialize(output, total = 0, minimum_output_duration: 1.0)
				@output = output
				@subject = subject
				
				@start_time = Progress.now
				
				if @output.interactive?
					@bar = Bar.new
					@lines = Lines.new(@output)
					@lines[0] = @bar
				end
				
				@current = 0
				@total = total
			end
			
			attr :subject
			attr :current
			attr :total
			
			def duration
				Progress.now - @start_time
			end
			
			def progress
				@current.to_f / @total.to_f
			end
			
			def remaining
				@total - @current
			end
			
			def average_duration
				if @current > 0
					duration / @current
				end
			end
			
			def estimated_remaining_time
				if average_duration = self.average_duration
					average_duration * remaining
				end
			end
			
			# Increase the amont of work done.
			def increment(amount = 1)
				@current += amount
				
				@bar&.update(@current, @total, self.to_s)
				@lines&.redraw(0)
				
				return self
			end
			
			# Increase the total size of the progress.
			def expand(amount = 1)
				@total += amount
				
				@bar&.update(@current, @total, self.to_s)
				@lines&.redraw(0)
				
				return self
			end
			
			def report(index, context, state)
				@lines&.[]=(index+1, Status.new(state, context))
				
				return self
			end
			
			def clear
				@lines&.clear
			end
			
			def to_s
				if estimated_remaining_time = self.estimated_remaining_time
					"#{@current}/#{@total} completed in #{formatted_duration(self.duration)}, #{formatted_duration(estimated_remaining_time)} remaining"
				else
					"#{@current}/#{@total} completed"
				end
			end
			
			private
			
			def formatted_duration(duration)
				seconds = duration.floor
				
				if seconds < 60.0
					return "#{seconds}s"
				end
				
				minutes = (duration / 60.0).floor
				seconds = (seconds - (minutes * 60)).round
				
				if minutes < 60.0
					return "#{minutes}m#{seconds}s"
				end
				
				hours = (minutes / 60.0).floor
				minutes = (minutes - (hours * 60)).round
				
				if hours < 24.0
					return "#{hours}h#{minutes}m"
				end
				
				days = (hours / 24.0).floor
				hours = (hours - (days * 24)).round
				
				return "#{days}d#{hours}h"
			end
		end
	end
end
