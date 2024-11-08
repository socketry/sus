# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "io/console"
require "stringio"

module Sus
	# Styled output output.
	module Output
		class Buffered
			def initialize(tee = nil)
				@chunks = Array.new
				@tee = tee
			end
			
			attr :chunks
			attr :tee
			
			def inspect
				if @tee
					"\#<#{self.class.name} #{@chunks.size} chunks -> #{@tee.class}>"
				else
					"\#<#{self.class.name} #{@chunks.size} chunks>"
				end
			end
			
			def buffered
				self.class.new(self)
			end
			
			def each(&block)
				@chunks.each(&block)
			end
			
			def append(buffer)
				@chunks.concat(buffer.chunks)
				@tee&.append(buffer)
			end
			
			def string
				io = StringIO.new
				Text.new(io).append(@chunks)
				return io.string
			end
			
			INDENT = [:indent].freeze
			
			def indent
				@chunks << INDENT
				@tee&.indent
			end
			
			OUTDENT = [:outdent].freeze
			
			def outdent
				@chunks << OUTDENT
				@tee&.outdent
			end
			
			def indented
				self.indent
				yield
			ensure
				self.outdent
			end
			
			def write(*arguments)
				@chunks << [:write, *arguments]
				@tee&.write(*arguments)
			end
			
			def puts(*arguments)
				@chunks << [:puts, *arguments]
				@tee&.puts(*arguments)
			end
			
			def assert(*arguments)
				@chunks << [:assert, *arguments]
				@tee&.assert(*arguments)
			end
			
			def skip(*arguments)
				@chunks << [:skip, *arguments]
				@tee&.skip(*arguments)
			end
			
			def error(*arguments)
				@chunks << [:error, *arguments]
				@tee&.error(*arguments)
			end
			
			def inform(*arguments)
				@chunks << [:inform, *arguments]
				@tee&.inform(*arguments)
			end
		end
	end
end
