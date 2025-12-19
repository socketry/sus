# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require_relative "respond_to"

module Sus
	# Represents an expectation that a method will be called on an object.
	class Receive
		# Initialize a new Receive expectation.
		# @parameter base [Object] The base object (usually self from Base).
		# @parameter method [Symbol] The method name to expect.
		# @yields {...} Optional block that returns the value to return from the method.
		def initialize(base, method, &block)
			@base = base
			@method = method
			
			@times = Times.new
			@arguments = nil
			@options = nil
			@block = nil
			
			@returning = block
		end
		
		# Print a representation of this expectation.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("receive ", :variable, @method.to_s, :reset)
		end
		
		# Specify that the method should be called with specific arguments.
		# @parameter predicate [Object] The predicate to match against the arguments.
		# @returns [Receive] Returns self for method chaining.
		def with_arguments(predicate)
			@arguments = WithArguments.new(predicate)
			return self
		end
		
		# Specify that the method should be called with specific keyword options.
		# @parameter predicate [Object] The predicate to match against the options.
		# @returns [Receive] Returns self for method chaining.
		def with_options(predicate)
			@options = WithOptions.new(predicate)
			return self
		end
		
		# Specify that the method should be called with a block.
		# @parameter predicate [Object] Optional predicate to match against the block.
		# @returns [Receive] Returns self for method chaining.
		def with_block(predicate = Be.new(:!=, nil))
			@block = WithBlock.new(predicate)
			return self
		end
		
		# Specify that the method should be called with specific arguments and options.
		# @parameter arguments [Array] The positional arguments to match.
		# @parameter options [Hash] The keyword arguments to match.
		# @returns [Receive] Returns self for method chaining.
		def with(*arguments, **options)
			with_arguments(Be.new(:==, arguments)) if arguments.any?
			with_options(Be.new(:==, options)) if options.any?
			return self
		end
		
		# Specify that the method should be called exactly once.
		# @returns [Receive] Returns self for method chaining.
		def once
			@times = Times.new(Be.new(:==, 1))
			return self
		end
		
		# Specify that the method should be called exactly twice.
		# @returns [Receive] Returns self for method chaining.
		def twice
			@times = Times.new(Be.new(:==, 2))
			return self
		end
		
		# Specify a predicate to match against the call count.
		# @parameter predicate [Object] The predicate to match against the call count.
		# @returns [Receive] Returns self for method chaining.
		def with_call_count(predicate)
			@times = Times.new(predicate)
			return self
		end
		
		# Specify the value to return when the method is called.
		# @parameter returning [Array] Values to return. If one value, returns it directly; if multiple, returns an array.
		# @yields {...} Optional block that computes the return value.
		# @returns [Receive] Returns self for method chaining.
		# @raises [ArgumentError] If both values and a block are provided.
		def and_return(*returning, &block)
			if block_given?
				if returning.any?
					raise ArgumentError, "Cannot specify both a block and returning values."
				end
				
				@returning = block
			elsif returning.size == 1
				@returning = proc{returning.first}
			else
				@returning = proc{returning}
			end
			
			return self
		end
		
		# Specify that the method should raise an exception when called.
		# @parameter exception [Class, String] The exception class or message to raise.
		# @returns [Receive] Returns self for method chaining.
		def and_raise(...)
			@returning = proc do
				raise(...)
			end
			
			return self
		end
		
		# Validate the method call arguments, options, and block.
		# @parameter mock [Mock] The mock instance.
		# @parameter assertions [Assertions] The assertions instance.
		# @parameter arguments [Array] The positional arguments.
		# @parameter options [Hash] The keyword arguments.
		# @parameter block [Proc, nil] The block argument.
		def validate(mock, assertions, arguments, options, block)
			return unless @arguments or @options or @block
			
			assertions.nested(self) do |assertions|
				@arguments.call(assertions, arguments) if @arguments
				@options.call(assertions, options) if @options
				@block.call(assertions, block) if @block
			end
		end
		
		# Evaluate this expectation against a subject.
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Object] The object to expect the method call on.
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				mock = @base.mock(subject)
				
				called = 0
				
				if call_original?
					mock.before(@method) do |*arguments, **options, &block|
						called += 1
						
						validate(mock, assertions, arguments, options, block)
					end
				else
					mock.replace(@method) do |*arguments, **options, &block|
						called += 1
						
						validate(mock, assertions, arguments, options, block)
						
						next @returning.call(*arguments, **options, &block)
					end
				end
				
				if @times
					assertions.defer do
						@times.call(assertions, called)
					end
				end
			end
		end
		
		# @returns [Boolean] Whether the original method should be called.
		def call_original?
			@returning.nil?
		end
		
		# Represents a constraint on method call arguments.
		class WithArguments
			# Initialize a new WithArguments constraint.
			# @parameter predicate [Object] The predicate to match against arguments.
			def initialize(predicate)
				@predicate = predicate
			end
			
			# Print a representation of this constraint.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("with arguments ", @predicate)
			end
			
			# Evaluate this constraint against arguments.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Array] The arguments to check.
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(@predicate)
				end
			end
		end
		
		# Represents a constraint on method call keyword options.
		class WithOptions
			# Initialize a new WithOptions constraint.
			# @parameter predicate [Object] The predicate to match against options.
			def initialize(predicate)
				@predicate = predicate
			end
			
			# Print a representation of this constraint.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("with options ", @predicate)
			end
			
			# Evaluate this constraint against options.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Hash] The options to check.
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(@predicate)
				end
			end
		end
		
		# Represents a constraint on method call block argument.
		class WithBlock
			# Initialize a new WithBlock constraint.
			# @parameter predicate [Object] The predicate to match against the block.
			def initialize(predicate)
				@predicate = predicate
			end
			
			# Print a representation of this constraint.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("with block", @predicate)
			end
			
			# Evaluate this constraint against a block.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Proc, nil] The block to check.
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					
					Expect.new(assertions, subject).not.to(Be == nil)
				end
			end
		end
		
		# Represents a constraint on method call count.
		class Times
			# A predicate that matches at least one call.
			AT_LEAST_ONCE = Be.new(:>=, 1)
			
			# Initialize a new Times constraint.
			# @parameter condition [Object] The predicate to match against the call count.
			def initialize(condition = AT_LEAST_ONCE)
				@condition = condition
			end
			
			# Print a representation of this constraint.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("with call count ", @condition)
			end
			
			# Evaluate this constraint against a call count.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Integer] The call count to check.
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(@condition)
				end
			end
		end
	end
	
	class Base
		# Create an expectation that a method will be called.
		# @parameter method [Symbol] The method name to expect.
		# @yields {...} Optional block that returns the value to return from the method.
		# @returns [Receive] A new Receive expectation.
		def receive(method, &block)
			Receive.new(self, method, &block)
		end
	end
end
