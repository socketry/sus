# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require_relative "output"
require_relative "clock"

require_relative "output/backtrace"

module Sus
	# Represents a collection of test assertions and their results. Tracks passed, failed, skipped, and errored assertions.
	class Assertions
		# Create a new assertions instance with default options.
		# @parameter options [Hash] Options to pass to {#initialize}.
		# @returns [Assertions] A new assertions instance.
		def self.default(**options)
			self.new(**options)
		end
		
		# Initialize a new assertions instance.
		# @parameter identity [Identity, nil] The identity used to identify this set of assertions.
		# @parameter target [Object, nil] The specific target of the assertions, e.g. the test case or nested test assertions.
		# @parameter output [Output] The output buffer used to capture output from the assertions.
		# @parameter inverted [Boolean] Whether the assertions are inverted with respect to the parent.
		# @parameter orientation [Boolean] Whether the assertions are positive or negative in general.
		# @parameter isolated [Boolean] Whether this set of assertions is isolated from the parent.
		# @parameter distinct [Boolean] Whether this set of assertions should be treated as a single statement.
		# @parameter measure [Boolean] Whether to measure execution time.
		# @parameter verbose [Boolean] Whether to output verbose information.
		def initialize(identity: nil, target: nil, output: Output.buffered, inverted: false, orientation: true, isolated: false, distinct: false, measure: false, verbose: false)
			# In theory, the target could carry the identity of the assertion group, but it's not really necessary, so we just handle it explicitly and pass it into any nested assertions.
			@identity = identity
			@target = target
			@output = output
			@inverted = inverted
			@orientation = orientation
			@isolated = isolated
			@distinct = distinct
			@verbose = verbose
			
			if measure
				@clock = Clock.start!
			else
				@clock = nil
			end
			
			@passed = Array.new
			@failed = Array.new
			@deferred = Array.new
			@skipped = Array.new
			@errored = Array.new
			
			@count = 0
		end
		
		# @attribute [Identity, nil] The identity that is used to identify this set of assertions.
		attr :identity
		
		# @attribute [Object, nil] The specific target of the assertions, e.g. the test case or nested test assertions.
		attr :target
		
		# @attribute [Output] The output buffer used to capture output from the assertions.
		attr :output
		
		# @attribute [Integer, nil] The nesting level of this set of assertions.
		attr :level
		
		# @attribute [Boolean] Whether this set of assertions is inverted, i.e. the assertions are expected to fail relative to the parent. Used for grouping assertions and ensuring they are added to the parent passed/failed array correctly.
		attr :inverted
		
		# @attribute [Boolean] The absolute orientation of this set of assertions, i.e. whether the assertions are expected to pass or fail regardless of the parent. Used for correctly formatting the output.
		attr :orientation
		
		# @attribute [Boolean] Whether this set of assertions is isolated from the parent. This is used to ensure that any deferred assertions are completed before the parent is completed. This is used by `receive` assertions which are deferred until the user code of the test has completed.
		attr :isolated
		
		# @attribute [Boolean] Distinct is used to identify a set of assertions as a single statement for the purpose of user feedback. It's used by top level ensure statements to ensure that error messages are captured and reported on those statements.
		attr :distinct
		
		# @attribute [Boolean] Whether to output verbose information.
		attr :verbose
		
		# @attribute [Clock, nil] The clock used to measure execution time, if measurement is enabled.
		attr :clock
		
		# @attribute [Array] Nested assertions that have passed.
		attr :passed
		
		# @attribute [Array] Nested assertions that have failed.
		attr :failed
		
		# @attribute [Array] Nested assertions that have been deferred.
		attr :deferred
		
		# @attribute [Array] Nested assertions that have been skipped.
		attr :skipped
		
		# @attribute [Array] Nested assertions that have errored.
		attr :errored
		
		# @attribute [Integer] The total number of assertions performed.
		attr :count
		
		# @returns [String] A string representation of the assertions instance.
		def inspect
			"\#<#{self.class} #{@passed.size} passed #{@failed.size} failed #{@deferred.size} deferred #{@skipped.size} skipped #{@errored.size} errored>"
		end
		
		# @returns [Hash] A hash containing the output text and location of the assertions.
		def message
			{
				text: @output.string,
				location: @identity&.to_location
			}
		end
		
		# @returns [Integer] The total number of assertions (passed, failed, deferred, skipped, and errored).
		def total
			@passed.size + @failed.size + @deferred.size + @skipped.size + @errored.size
		end
		
		# Print a summary of the assertions to the output.
		# @parameter output [Output] The output target.
		# @parameter verbose [Boolean] Whether to include verbose information.
		def print(output, verbose: @verbose)
			if verbose && @target
				@target.print(output)
				output.write(": ")
			end
			
			if @count.zero?
				output.write("0 assertions")
			else
				if @passed.any?
					output.write(:passed, @passed.size, " passed", :reset, " ")
				end
				
				if @failed.any?
					output.write(:failed, @failed.size, " failed", :reset, " ")
				end
				
				if @deferred.any?
					output.write(:deferred, @deferred.size, " deferred", :reset, " ")
				end
				
				if @skipped.any?
					output.write(:skipped, @skipped.size, " skipped", :reset, " ")
				end
				
				if @errored.any?
					output.write(:errored, @errored.size, " errored", :reset, " ")
				end
				
				output.write("out of ", self.total, " total (", @count, " assertions)")
			end
		end
		
		# Print a message to the output buffer.
		# @parameter message [Array] The message parts to print.
		def puts(*message)
			@output.puts(:indent, *message)
		end
		
		# @returns [Boolean] Whether there are no assertions (passed, failed, deferred, skipped, or errored).
		def empty?
			@passed.empty? and @failed.empty? and @deferred.empty? and @skipped.empty? and @errored.empty?
		end
		
		# @returns [Boolean] Whether all assertions passed and none errored.
		def passed?
			if @inverted
				# Inverted assertions:
				@failed.any? and @errored.empty?
			else
				# Normal assertions:
				@failed.empty? and @errored.empty?
			end
		end
		
		# @returns [Boolean] Whether any assertions failed or errored.
		def failed?
			!self.passed?
		end
		
		# @returns [Boolean] Whether any assertions errored.
		def errored?
			@errored.any?
		end
		
		# Represents a single assertion result.
		class Assert
			# Initialize a new assertion result.
			# @parameter identity [Identity, nil] The identity of the assertion.
			# @parameter backtrace [Array] The backtrace where the assertion was made.
			# @parameter assertions [Assertions] The assertions instance that contains this assertion.
			def initialize(identity, backtrace, assertions)
				@identity = identity
				@backtrace = backtrace
				@assertions = assertions
			end
			
			# @attribute [Identity, nil] The identity of the assertion.
			attr :identity
			
			# @attribute [Array] The backtrace where the assertion was made.
			attr :backtrace
			
			# @attribute [Assertions] The assertions instance that contains this assertion.
			attr :assertions
			
			# @yields {|assert| ...} Yields this assertion as a failure.
			def each_failure(&block)
				yield self
			end
			
			# @returns [Hash] A hash containing the output text and location of the assertion.
			def message
				{
					# It's possible that several Assert instances might share the same output text. This is because the output is buffered for each test and each top-level test expectation.
					text: @assertions.output.string,
					location: @identity&.to_location
				}
			end
		end
		
		# Make an assertion about a condition.
		# @parameter condition [Boolean] The condition to assert.
		# @parameter message [String | Nil] Optional message describing the assertion.
		def assert(condition, message = nil)
			@count += 1
			
			identity = @identity&.scoped
			backtrace = Output::Backtrace.first(identity)
			assert = Assert.new(identity, backtrace, self)
			
			if condition
				@passed << assert
				@output.assert(condition, @orientation, message || "assertion passed", backtrace)
			else
				@failed << assert
				@output.assert(condition, @orientation, message || "assertion failed", backtrace)
			end
		end
		
		# Iterate over all failures in this assertions instance.
		# @yields {|failure| ...} Each failure (failed assertion or error).
		# @returns [Enumerator] An enumerator if no block is given.
		def each_failure(&block)
			return to_enum(__method__) unless block_given?
			
			if self.failed? and @distinct
				return yield(self)
			end
			
			@failed.each do |assertions|
				assertions.each_failure(&block)
			end
			
			@errored.each do |assertions|
				assertions.each_failure(&block)
			end
		end
		
		# Skip this set of assertions with a reason.
		# @parameter reason [String] The reason for skipping.
		def skip(reason)
			@output.skip(reason, @identity&.scoped)
			
			@skipped << self
		end
		
		# Print an informational message during test execution.
		# @parameter message [String | Nil] The message to print, or a block that returns a message.
		def inform(message = nil)
			if message.nil? and block_given?
				begin
					message = yield
				rescue => error
					message = error.full_message
				end
			end
			
			@output.inform(message, @identity&.scoped)
		end
		
		# Add a deferred assertion that will be resolved later.
		# @yields {|assertions| ...} The block that will be called to resolve the deferred assertion.
		def defer(&block)
			@deferred << block
		end
		
		# @returns [Boolean] Whether there are any deferred assertions.
		def deferred?
			@deferred.any?
		end
		
		# Resolve all deferred assertions in order.
		def resolve!
			@output.indented do
				while block = @deferred.shift
					block.call(self)
				end
			end
		end
		
		# Represents an error that occurred during test execution.
		class Error
			# Initialize a new error result.
			# @parameter identity [Identity, nil] The identity where the error occurred.
			# @parameter error [Exception] The exception that was raised.
			def initialize(identity, error)
				@identity = identity
				@error = error
			end
			
			# @attribute [Identity, nil] The identity where the error occurred.
			attr :identity
			
			# @attribute [Exception] The exception that was raised.
			attr :error
			
			# @yields {|error| ...} Yields this error as a failure.
			def each_failure(&block)
				yield self
			end
			
			# @returns [Hash] A hash containing the error message and location.
			def message
				{
					text: @error.full_message,
					location: @identity&.to_location
				}
			end
		end
		
		# Record an error that occurred during test execution.
		# @parameter error [Exception] The exception that was raised.
		def error!(error)
			identity = @identity&.scoped(error.backtrace_locations)
			
			@errored << Error.new(identity, error)
			
			# TODO consider passing `identity`.
			@output.error(error, @identity)
		end
		
		# Create a nested set of assertions.
		# @parameter target [Object] The target object for the nested assertions.
		# @parameter identity [Identity, nil] The identity for the nested assertions.
		# @parameter isolated [Boolean] Whether the nested assertions are isolated from the parent.
		# @parameter distinct [Boolean] Whether the nested assertions should be treated as a single statement.
		# @parameter inverted [Boolean] Whether the nested assertions are inverted.
		# @parameter options [Hash] Additional options to pass to the nested assertions instance.
		# @yields {|assertions| ...} The nested assertions instance.
		# @returns [Object] The result of the block.
		def nested(target, identity: @identity, isolated: false, distinct: false, inverted: false, **options)
			result = nil
			
			# Isolated assertions need to have buffered output so they can be replayed if they fail:
			if isolated or distinct
				output = @output.buffered
			else
				output = @output
			end
			
			# Inverting a nested assertions causes the orientation to flip:
			if inverted
				orientation = !@orientation
			else
				orientation = @orientation
			end
			
			output.puts(:indent, target)
			
			assertions = self.class.new(identity: identity, target: target, output: output, isolated: isolated, inverted: inverted, orientation: orientation, distinct: distinct, verbose: @verbose, **options)
			
			output.indented do
				begin
					result = yield(assertions)
				rescue StandardError => error
					assertions.error!(error)
				end
			end
			
			# Some assertions are deferred until the end of the test, e.g. expecting a method to be called. This scope is managed by the {add} method. If there are no deferred assertions, then we can add the child assertions right away. Otherwise, we append the child assertions to our own list of deferred assertions. When an assertions instance is marked as `isolated`, it will force all deferred assertions to be resolved. It's also at this time, we should conclude measuring the duration of the test.
			assertions.resolve_into(self)
			
			return result
		end
		
		# Add child assertions that were nested to this instance.
		# @parameter assertions [Assertions] The child assertions to add.
		def add(assertions)
			# All child assertions should be resolved by this point:
			raise "Nested assertions must be fully resolved!" if assertions.deferred?
			
			if assertions.append?
				# If we are isolated, we merge all child assertions into the parent as a single entity:
				append!(assertions)
			else
				# Otherwise, we append all child assertions into the parent assertions:
				merge!(assertions)
			end
		end
		
		protected
		
		def resolve_into(parent)
			# If the assertions should be an isolated group, make sure any deferred assertions are resolved:
			if @isolated and self.deferred?
				self.resolve!
			end
			
			# Check if the child assertions are deferred, and if so, add them to our own list of deferred assertions:
			if self.deferred?
				parent.defer do
					output.puts(:indent, @target)
					self.resolve!
					
					@clock&.stop!
					parent.add(self)
				end
			else
				@clock&.stop!
				parent.add(self)
			end
		end
		
		# Whether the child assertions should be merged into the parent assertions.
		def append?
			@isolated || @inverted || @distinct
		end
		
		private
		
		def append!(assertions)
			@count += assertions.count
			
			if assertions.errored?
				@errored << assertions
			elsif assertions.passed?
				@passed << assertions
				
				# if @verbose
				# 	@output.write(:indent, :passed, pass_prefix, :reset)
				# 	self.print(@output, verbose: false)
				# 	@output.puts
				# end
			else
				@failed << assertions
				
				# @output.write(:indent, :failed, fail_prefix, :reset)
				# self.print(@output, verbose: false)
				# @output.puts
			end
			
			@skipped.concat(assertions.skipped)
		end
		
		# Concatenate the child assertions into this instance.
		def merge!(assertions)
			@count += assertions.count
			@passed.concat(assertions.passed)
			@failed.concat(assertions.failed)
			@deferred.concat(assertions.deferred)
			@skipped.concat(assertions.skipped)
			@errored.concat(assertions.errored)
			
			# if @verbose
			# 	@output.write(:indent)
			# 	self.print(@output, verbose: false)
			# 	@output.puts
			# end
		end
	end
end
