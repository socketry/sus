# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "io/console"

module Sus
	module Output
		# Represents a line buffer for managing multiple lines of output on a terminal.
		class Lines
			# Initialize a new Lines buffer.
			# @parameter output [Output] The output handler to write to.
			def initialize(output)
				@output = output
				@lines = []
				
				@current_count = 0
			end
			
			# @returns [Integer] The height of the terminal.
			def height
				@output.size.first
			end
			
			# Set a line at the given index.
			# @parameter index [Integer] The line index.
			# @parameter line [Object] The line content (should respond to #print).
			def []= index, line
				@lines[index] = line
				
				redraw(index)
			end
			
			# Clear all lines.
			def clear
				@lines.clear
				write
			end
			
			# Redraw a specific line or all lines.
			# @parameter index [Integer] The line index to redraw.
			def redraw(index)
				if index < @current_count
					update(index, @lines[index])
				else
					write
				end
			end
			
			private
			
			def soft_wrap
				@output.write("\e[?7l")
				
				yield
			ensure
				@output.write("\e[?7h")
			end
			
			def origin
				if @current_count > 0
					@output.write("\e[#{@current_count}F\e[J")
				end
				
				@current_count = 0
			end
			
			def write
				origin
				
				height = self.height
				
				soft_wrap do
					@lines.each do |line|
						break if (@current_count+1) >= height
						
						if line
							line.print(@output)
						else
							@output.puts
						end
						
						@current_count += 1
					end
				end
			end
			
			def update(index, line)
				offset = @current_count - index
				
				@output.write("\e[#{offset}F\e[K")
				
				soft_wrap do
					line.print(@output)
				end
				
				if offset > 1
					@output.write("\e[#{offset-1}E")
				end
			end
		end
	end
end
