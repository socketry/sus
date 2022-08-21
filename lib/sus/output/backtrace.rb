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
	module Output
		# Print out a backtrace relevant to the given test identity if provided.
		class Backtrace
			def self.first(identity = nil)
				self.new(caller_locations(1), identity&.path, 1)
			end
			
			def self.for(exception, identity = nil)
				self.new(exception.backtrace_locations, identity&.path)
			end
			
			def initialize(stack, root = nil, limit = nil)
				@stack = stack
				@root = root
				@limit = limit
			end
			
			def filter(root = @root)
				if @root
					stack = @stack.select do |frame|
						frame.path.start_with?(@root)
					end
				else
					stack = @stack
				end
				
				if @limit
					stack = stack.take(@limit)
				end
				
				return stack
			end
			
			def print(output)
				if @limit == 1
					filter.each do |frame|
						output.puts " ", :path, frame.path, :line, ":", frame.lineno
					end
				else
					output.puts
					
					output.indented do
						filter.each do |frame|
							output.puts :indent, :path, frame.path, :line, ":", frame.lineno, :reset, " ", frame.label
						end
					end
				end
			end
		end
	end
end
