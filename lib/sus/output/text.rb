# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "messages"
require_relative "buffered"

module Sus
	module Output
		class Text
			include Messages
			
			def initialize(io)
				@io = io
				
				@styles = {reset: self.reset}
				
				@indent = String.new
				@styles[:indent] = @indent
			end
			
			attr :styles
			
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
