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
			
			attr :output
			
			def each(&block)
				@chunks.each(&block)
			end
			
			def append(buffer)
				@chunks.concat(buffer.output)
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
		end
	end
end
