# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "bar"
require_relative "status"
require_relative "lines"

module Sus
	module Output
		# Represents a progress tracker for test execution.
		class Progress
			# Get the current monotonic time.
			# @returns [Float] The current time in seconds.
			def self.now
				::Process.clock_gettime(Process::CLOCK_MONOTONIC)
			end
			
			# Initialize a new Progress tracker.
			# @parameter output [Output] The output handler.
			# @parameter total [Integer] The total number of items to track.
			# @parameter minimum_output_duration [Float] Minimum duration before showing output (unused).
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
			
			# @attribute [Object, nil] The subject being tracked.
			attr :subject
			
			# @attribute [Integer] The current progress value.
			attr :current
			
			# @attribute [Integer] The total value.
			attr :total
			
			# @returns [Float] The elapsed duration in seconds.
			def duration
				Progress.now - @start_time
			end
			
			# @returns [Float] The progress as a fraction (0.0 to 1.0).
			def progress
				@current.to_f / @total.to_f
			end
			
			# @returns [Integer] The remaining items to process.
			def remaining
				@total - @current
			end
			
			# @returns [Float, nil] The average duration per item, or nil if no items completed.
			def average_duration
				if @current > 0
					duration / @current
				end
			end
			
			# @returns [Float, nil] The estimated remaining time, or nil if cannot be calculated.
			def estimated_remaining_time
				if average_duration = self.average_duration
					average_duration * remaining
				end
			end
			
			# Increase the amount of work done.
			# @parameter amount [Integer] The amount to increment by.
			# @returns [Progress] Returns self for method chaining.
			def increment(amount = 1)
				@current += amount
				
				@bar&.update(@current, @total, self.to_s)
				@lines&.redraw(0)
				
				return self
			end
			
			# Increase the total size of the progress.
			# @parameter amount [Integer] The amount to expand by.
			# @returns [Progress] Returns self for method chaining.
			def expand(amount = 1)
				@total += amount
				
				@bar&.update(@current, @total, self.to_s)
				@lines&.redraw(0)
				
				return self
			end
			
			# Report the status of a specific item.
			# @parameter index [Integer] The index of the item.
			# @parameter context [Object] The context to display.
			# @parameter state [Symbol] The state (:free or :busy).
			# @returns [Progress] Returns self for method chaining.
			def report(index, context, state)
				@lines&.[]=(index+1, Status.new(state, context))
				
				return self
			end
			
			# Clear the progress display.
			def clear
				@lines&.clear
			end
			
			# @returns [String] A string representation of the progress.
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
