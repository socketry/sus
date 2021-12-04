# frozen_string_literal: true

# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'io/console'
require 'stringio'

module Sus
	# Styled output output.
	module Output
		class Text
			def initialize(output)
				@output = output
				@styles = {reset: self.reset}
			end
			
			def interactive?
				@output.tty?
			end
			
			def append(output)
				output.write(@output.string)
			end
			
			attr :output
			 
			def buffered
				self.dup.tap do |output|
					output.instance_variable_set(:@output, StringIO.new)
				end
			end
			
			def [] key
				@styles[key]
			end
			
			def []= key, value
				@styles[key] = value
			end
			
			def size
				[24, 80]
			end
			
			def width
				size.last
			end
			
			def colors?
				false
			end
			
			def style(foreground, background = nil, *attributes)
			end
			
			def reset
			end
			
			def write(*arguments, style: nil)
				if style and prefix = self[style]
					@output.write(prefix)
					@output.write(*arguments)
					@output.write(self.reset)
				else
					@output.write(*arguments)
				end
			end
			
			def puts(*arguments, style: nil)
				if style and prefix = self[style]
					@output.write(prefix)
					@output.puts(*arguments)
					@output.write(self.reset)
				else
					@output.puts(*arguments)
				end
			end
			
			# Print out the given arguments.
			# When the argument is a symbol, look up the style and inject it into the output stream.
			# When the argument is a proc/lambda, call it with self as the argument.
			# When the argument is anything else, write it directly to the output.
			def print(*arguments)
				arguments.each do |argument|
					case argument
					when Symbol
						@output.write(self[argument])
					when Proc
						argument.call(self)
					else
						if argument.respond_to?(:print)
							argument.print(self)
						else
							@output.write(argument)
						end
					end
				end
			end
			
			# Print out the arguments as per {#print}, followed by the reset sequence and a newline.
			def print_line(*arguments)
				print(*arguments)
				@output.puts(self.reset)
			end
		end
	end
end
