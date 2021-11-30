# frozen_string_literal: true

# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Sus
	module Terminal
		class Bar
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
			
			def initialize(current = 0, total = 0, message = nil)
				@maximum_message_width = 0
				
				@current = current
				@total = total
				@message = message
			end
			
			def update(current, total, message)
				@current = current
				@total = total
				@message = message
			end
			
			def self.register(terminal)
				terminal[:progress_bar] ||= terminal.style(:blue, :white)
			end
			
			MINIMUM_WIDTH = 8
			MESSAGE_SUFFIX = ": "
			
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
					output.print(message)
				end
				
				output.print(
					:progress_bar, draw(value, width), :reset,
				)
				
				output.print_line
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
