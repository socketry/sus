# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

module Sus
	module Output
		# Print out a backtrace relevant to the given test identity if provided.
		class Backtrace
			def self.first(identity = nil)
				# This implementation could be a little more efficient.
				self.new(caller_locations(1), identity&.path, 1)
			end
			
			def self.for(exception, identity = nil)
				# I've disabled the root filter here, because partial backtraces are not very useful.
				# We might want to do something to improve presentation of the backtrace based on the root instead.
				self.new(extract_stack(exception), identity&.path)
			end
			
			Location = Struct.new(:path, :lineno, :label)
			
			def self.extract_stack(exception)
				if stack = exception.backtrace_locations
					return stack
				elsif stack = exception.backtrace
					return stack.map do |line|
						Location.new(*line.split(":", 3))
					end
				else
					[]
				end
			end
			
			def initialize(stack, root = nil, limit = nil)
				@stack = stack
				@root = root
				@limit = limit
			end
			
			attr :stack
			attr :root
			attr :limit
			
			def filter(root: @root, limit: @limit)
				if root
					if limit
						return @stack.lazy.select do |frame|
							frame.path.start_with?(root)
						end.first(limit)
					else
						return up_to_and_matching(@stack) do |frame|
							frame.path.start_with?(root)
						end
					end
				elsif limit
					return @stack.first(limit)
				else
					return @stack
				end
			end
			
			def print(output)
				if @limit == 1
					filter.each do |frame|
						output.write " ", :path, frame.path, :line, ":", frame.lineno
					end
				else
					output.indented do
						filter.each do |frame|
							output.puts :indent, :path, frame.path, :line, ":", frame.lineno, :reset, " ", frame.label
						end
					end
				end
			end
			
			private def up_to_and_matching(things, &block)
				preface = true
				things.select do |thing|
					if preface
						if yield(thing)
							preface = false
						end
						true
					elsif yield(thing)
						true
					else
						false
					end
				end
			end
		end
	end
end
