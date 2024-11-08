# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "output"
require_relative "clock"

require_relative "output/backtrace"

module Sus
	class Assertions
		def self.default(**options)
			self.new(**options)
		end
		
		# @parameter orientation [Boolean] Whether the assertions are positive or negative in general.
		# @parameter inverted [Boolean] Whether the assertions are inverted with respect to the parent.
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
		
		# The identity that is used to identify this set of assertions.
		attr :identity
		
		# The specific target of the assertions, e.g. the test case or nested test assertions.
		attr :target
		
		# The output buffer used to capture output from the assertions.
		attr :output
		
		# The nesting level of this set of assertions.
		attr :level
		
		# Whether this aset of assertions is inverted, i.e. the assertions are expected to fail relative to the parent. Used for grouping assertions and ensuring they are added to the parent passed/failed array correctly.
		attr :inverted
		
		# The absolute orientation of this set of assertions, i.e. whether the assertions are expected to pass or fail regardless of the parent. Used for correctly formatting the output.
		attr :orientation
		
		# Whether this set of assertions is isolated from the parent. This is used to ensure that any deferred assertions are competed before the parent is completed. This is used by `receive` assertions which are deferred until the user code of the test has completed.
		attr :isolated
		
		# Distinct is used to identify a set of assertions as a single statement for the purpose of user feedback. It's used by top level ensure statements to ensure that error messages are captured and reported on those statements.
		attr :distinct
		
		attr :verbose
		
		attr :clock
		
		# Nested assertions that have passed.
		attr :passed
		
		# Nested assertions that have failed.
		attr :failed
		
		# Nested assertions have been deferred.
		attr :deferred
		
		attr :skipped
		attr :errored
		
		# The total number of assertions performed:
		attr :count
		
		def inspect
			"\#<#{self.class} #{@passed.size} passed #{@failed.size} failed #{@deferred.size} deferred #{@skipped.size} skipped #{@errored.size} errored>"
		end
		
		def message
			{
				text: @output.string,
				location: @identity&.to_location
			}
		end
		
		def total
			@passed.size + @failed.size + @deferred.size + @skipped.size + @errored.size
		end
		
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
		
		def puts(*message)
			@output.puts(:indent, *message)
		end
		
		def empty?
			@passed.empty? and @failed.empty? and @deferred.empty? and @skipped.empty? and @errored.empty?
		end
		
		def passed?
			if @inverted
				# Inverted assertions:
				@failed.any? and @errored.empty?
			else
				# Normal assertions:
				@failed.empty? and @errored.empty?
			end
		end
		
		def failed?
			!self.passed?
		end
		
		def errored?
			@errored.any?
		end
		
		class Assert
			def initialize(identity, backtrace, assertions)
				@identity = identity
				@backtrace = backtrace
				@assertions = assertions
			end
			
			attr :identity
			attr :backtrace
			attr :assertions
			
			def each_failure(&block)
				yield self
			end
			
			def message
				{
					# It's possible that several Assert instances might share the same output text. This is because the output is buffered for each test and each top-level test expectation.
					text: @assertions.output.string,
					location: @identity&.to_location
				}
			end
		end
		
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
		
		def skip(reason)
			@output.skip(reason, @identity&.scoped)
			
			@skipped << self
		end
		
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
		
		# Add deferred assertions.
		def defer(&block)
			@deferred << block
		end
		
		# Whether there are any deferred assertions.
		def deferred?
			@deferred.any?
		end
		
		# This resolves all deferred assertions in order.
		def resolve!
			@output.indented do
				while block = @deferred.shift
					block.call(self)
				end
			end
		end
		
		class Error
			def initialize(identity, error)
				@identity = identity
				@error = error
			end
			
			attr :identity
			attr :error
			
			def each_failure(&block)
				yield self
			end
			
			def message
				{
					text: @error.full_message,
					location: @identity&.to_location
				}
			end
		end
		
		def error!(error)
			identity = @identity&.scoped(error.backtrace_locations)
			
			@errored << Error.new(identity, error)
			
			# TODO consider passing `identity`.
			@output.error(error, @identity)
		end
		
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
		
		# Add the child assertions which were nested to this instance.
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
