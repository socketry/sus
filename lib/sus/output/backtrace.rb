# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

module Sus
	module Output
		# Represents a backtrace for displaying error locations.
		class Backtrace
			# Create a backtrace from the first caller location.
			# @parameter identity [Identity, nil] Optional identity to filter by path.
			# @returns [Backtrace] A new Backtrace instance.
			def self.first(identity = nil)
				# This implementation could be a little more efficient.
				self.new(caller_locations(1), identity&.path, 1)
			end
			
			# Create a backtrace from an exception.
			# @parameter exception [Exception] The exception to extract the backtrace from.
			# @parameter identity [Identity, nil] Optional identity to filter by path.
			# @returns [Backtrace] A new Backtrace instance.
			def self.for(exception, identity = nil)
				# I've disabled the root filter here, because partial backtraces are not very useful.
				# We might want to do something to improve presentation of the backtrace based on the root instead.
				self.new(extract_stack(exception), identity&.path)
			end
			
			# Represents a location in a backtrace.
			Location = Struct.new(:path, :lineno, :label)
			
			# Extract the stack trace from an exception.
			# @parameter exception [Exception] The exception to extract from.
			# @returns [Array] An array of location objects.
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
			
			# Initialize a new Backtrace.
			# @parameter stack [Array] The stack trace locations.
			# @parameter root [String, nil] Optional root path to filter by.
			# @parameter limit [Integer, nil] Optional limit on the number of frames.
			def initialize(stack, root = nil, limit = nil)
				@stack = stack
				@root = root
				@limit = limit
			end
			
			# @attribute [Array] The stack trace locations.
			attr :stack
			
			# @attribute [String, nil] The root path to filter by.
			attr :root
			
			# @attribute [Integer, nil] The limit on the number of frames.
			attr :limit
			
			# Filter the backtrace by root path and limit.
			# @parameter root [String, nil] Optional root path to filter by.
			# @parameter limit [Integer, nil] Optional limit on the number of frames.
			# @returns [Array, Enumerator] The filtered stack trace.
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
			
			# Print the backtrace to the output.
			# @parameter output [Output] The output handler.
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
			
			# Select items up to and matching a condition.
			# @parameter things [Enumerable] The items to filter.
			# @yields {|thing| ...} The condition to match.
			# @returns [Array] The filtered items.
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
