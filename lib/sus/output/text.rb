# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "messages"
require_relative "buffered"

module Sus
	module Output
		# Represents a plain text output handler without color support.
		class Text
			include Messages
			
			# Initialize a new Text output handler.
			# @parameter io [IO] The IO object to write to.
			def initialize(io)
				@io = io
				
				@styles = {reset: self.reset}
				
				@indent = String.new
				@styles[:indent] = @indent
			end
			
			# @attribute [Hash] The style definitions.
			attr :styles
			
			# Create a buffered output handler.
			# @returns [Buffered] A new Buffered instance.
			def buffered
				Buffered.new(self)
			end
			
			# Append and replay chunks from a buffer.
			# @parameter buffer [Buffered] The buffer to append from.
			def append(buffer)
				buffer.each do |operation|
					self.public_send(*operation)
				end
			end
			
			# @attribute [IO] The IO object to write to.
			attr :io
			
			# The indentation string.
			INDENTATION = "\t"
			
			# Increase indentation level.
			def indent
				@indent << INDENTATION
			end
			
			# Decrease indentation level.
			def outdent
				@indent.slice!(INDENTATION)
			end
			
			# Execute a block with increased indentation.
			# @yields {...} The block to execute.
			def indented
				self.indent
				yield
			ensure
				self.outdent
			end
			
			# @returns [Boolean] Whether the IO is interactive (a TTY).
			def interactive?
				@io.tty?
			end
			
			# Get a style by key.
			# @parameter key [Symbol] The style key.
			# @returns [String] The style value.
			def [] key
				@styles[key]
			end
			
			# Set a style by key.
			# @parameter key [Symbol] The style key.
			# @parameter value [String] The style value.
			def []= key, value
				@styles[key] = value
			end
			
			# @returns [Array(Integer)] The terminal size [height, width] (defaults to [24, 80]).
			def size
				[24, 80]
			end
			
			# @returns [Integer] The terminal width (defaults to 80).
			def width
				size.last
			end
			
			# @returns [Boolean] Always returns false, as Text output doesn't support colors.
			def colors?
				false
			end
			
			# Create a style string (no-op for Text output).
			# @parameter foreground [Symbol, nil] The foreground color.
			# @parameter background [Symbol, nil] The background color.
			# @parameter attributes [Array] Additional style attributes.
			# @returns [String] An empty string.
			def style(foreground, background = nil, *attributes)
			end
			
			# @returns [String] An empty string (no reset needed for plain text).
			def reset
			end
			
			# Print out the given arguments.
			# When the argument is a symbol, look up the style and inject it into the io stream.
			# When the argument is a proc/lambda, call it with self as the argument.
			# When the argument is anything else, write it directly to the io.
			# @parameter arguments [Array] The arguments to write.
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
			
			# Print out the arguments as per {#write}, followed by the reset sequence and a newline.
			# @parameter arguments [Array] The arguments to write.
			def puts(*arguments)
				write(*arguments)
				@io.puts(self.reset)
			end
		end
	end
end
