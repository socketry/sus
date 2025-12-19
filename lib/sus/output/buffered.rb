# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "io/console"
require "stringio"

module Sus
	module Output
		# Represents a buffered output handler that stores output operations for later replay.
		class Buffered
			# Initialize a new Buffered output handler.
			# @parameter tee [Output, nil] Optional output handler to tee output to.
			def initialize(tee = nil)
				@chunks = Array.new
				@tee = tee
			end
			
			# @attribute [Array] The stored output chunks.
			attr :chunks
			
			# @attribute [Output, nil] The output handler to tee to.
			attr :tee
			
			# @returns [String] A string representation of this buffered output.
			def inspect
				if @tee
					"\#<#{self.class.name} #{@chunks.size} chunks -> #{@tee.class}>"
				else
					"\#<#{self.class.name} #{@chunks.size} chunks>"
				end
			end
			
			# Create a nested buffered output handler.
			# @returns [Buffered] A new Buffered instance that tees to this one.
			def buffered
				self.class.new(self)
			end
			
			# Iterate over stored chunks.
			# @yields {|chunk| ...} Each stored chunk.
			def each(&block)
				@chunks.each(&block)
			end
			
			# Append chunks from another buffer.
			# @parameter buffer [Buffered] The buffer to append from.
			def append(buffer)
				@chunks.concat(buffer.chunks)
				@tee&.append(buffer)
			end
			
			# @returns [String] The buffered output as a string.
			def string
				io = StringIO.new
				Text.new(io).append(@chunks)
				return io.string
			end
			
			# The indent operation marker.
			INDENT = [:indent].freeze
			
			# Increase indentation level.
			def indent
				@chunks << INDENT
				@tee&.indent
			end
			
			# The outdent operation marker.
			OUTDENT = [:outdent].freeze
			
			# Decrease indentation level.
			def outdent
				@chunks << OUTDENT
				@tee&.outdent
			end
			
			# Execute a block with increased indentation.
			# @yields {...} The block to execute.
			def indented
				self.indent
				yield
			ensure
				self.outdent
			end
			
			# Write output.
			# @parameter arguments [Array] The arguments to write.
			def write(*arguments)
				@chunks << [:write, *arguments]
				@tee&.write(*arguments)
			end
			
			# Write output followed by a newline.
			# @parameter arguments [Array] The arguments to write.
			def puts(*arguments)
				@chunks << [:puts, *arguments]
				@tee&.puts(*arguments)
			end
			
			# Record an assertion.
			# @parameter arguments [Array] The assertion arguments.
			def assert(*arguments)
				@chunks << [:assert, *arguments]
				@tee&.assert(*arguments)
			end
			
			# Record a skip.
			# @parameter arguments [Array] The skip arguments.
			def skip(*arguments)
				@chunks << [:skip, *arguments]
				@tee&.skip(*arguments)
			end
			
			# Record an error.
			# @parameter arguments [Array] The error arguments.
			def error(*arguments)
				@chunks << [:error, *arguments]
				@tee&.error(*arguments)
			end
			
			# Record an informational message.
			# @parameter arguments [Array] The message arguments.
			def inform(*arguments)
				@chunks << [:inform, *arguments]
				@tee&.inform(*arguments)
			end
		end
	end
end
