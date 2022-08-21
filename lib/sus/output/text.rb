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
require_relative 'buffered'

module Sus
	# Styled io io.
	module Output
		class Text
			def initialize(io)
				@io = io
				
				@styles = {reset: self.reset}
				
				@indent = String.new
				@styles[:indent] = @indent
			end
			
			def buffered
				Buffered.new(self)
			end
			
			def append(buffer)
				buffer.each do |operation|
					self.public_send(*operation)
				end
			end
			
			attr :io
			
			INDENTATION = "\t"
			
			def indent
				@indent << INDENTATION
			end
			
			def outdent
				@indent.slice!(INDENTATION)
			end
			
			def indented
				self.indent
				yield
			ensure
				self.outdent
			end
			
			def interactive?
				@io.tty?
			end
			
			attr :io
			
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
			
			# Print out the given arguments.
			# When the argument is a symbol, look up the style and inject it into the io stream.
			# When the argument is a proc/lambda, call it with self as the argument.
			# When the argument is anything else, write it directly to the io.
			def write(*arguments)
				arguments.each do |argument|
					case argument
					when Symbol
						@io.write(self[argument])
					when Proc
						argument.call(self)
					else
						if argument.respond_to?(:print)
							argument.print(self)
						else
							@io.write(argument)
						end
					end
				end
			end
			
			# Print out the arguments as per {#print}, followed by the reset sequence and a newline.
			def puts(*arguments)
				write(*arguments)
				@io.puts(self.reset)
			end
		end
	end
end
