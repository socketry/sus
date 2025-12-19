# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

module Sus
	module Output
		# Represents a progress bar for displaying test execution progress.
		class Bar
			# Unicode block characters for drawing the progress bar.
			BLOCK = [
				" ",
				"▏",
				"▎",
				"▍",
				"▌",
				"▋",
				"▊",
				"▉",
				"█",
			]
			
			# Initialize a new progress bar.
			# @parameter current [Integer] The current progress value.
			# @parameter total [Integer] The total value.
			# @parameter message [String, nil] Optional message to display.
			def initialize(current = 0, total = 0, message = nil)
				@maximum_message_width = 0
				
				@current = current
				@total = total
				@message = message
			end
			
			# Update the progress bar values.
			# @parameter current [Integer] The current progress value.
			# @parameter total [Integer] The total value.
			# @parameter message [String, nil] Optional message to display.
			def update(current, total, message)
				@current = current
				@total = total
				@message = message
			end
			
			# Register progress bar styling with an output handler.
			# @parameter output [Output] The output handler to register with.
			def self.register(output)
				output[:progress_bar] ||= output.style(:blue, :white)
			end
			
			# The minimum width for the progress bar.
			MINIMUM_WIDTH = 8
			
			# The suffix to append to messages.
			MESSAGE_SUFFIX = ": "
			
			# Print the progress bar to the output.
			# @parameter output [Output] The output handler.
			def print(output)
				width = output.width
				
				unless @total.zero?
					value = @current.to_f / @total.to_f
				else
					value = 0.0
				end
				
				if @message
					message = @message + MESSAGE_SUFFIX
					if message.size > @maximum_message_width
						@maximum_message_width = message.size
					end
					
					if @maximum_message_width < (width - MINIMUM_WIDTH)
						width -= @maximum_message_width
						message = message.rjust(@maximum_message_width)
					else
						@maximum_message_width = 0
						message = nil
					end
				end
				
				if message
					output.write(message)
				end
				
				output.write(
					:progress_bar, draw(value, width), :reset,
				)
				
				output.puts
			end
			
			private
			
			def draw(value, width)
				blocks = width * value
				full_blocks = blocks.floor
				partial_block = ((blocks - full_blocks) * BLOCK.size).floor
				
				if partial_block.zero?
					BLOCK.last * full_blocks
				else
					"#{BLOCK.last * full_blocks}#{BLOCK[partial_block]}"
				end.ljust(width)
			end
		end
	end
end
