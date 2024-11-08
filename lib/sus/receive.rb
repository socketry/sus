# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require_relative "respond_to"

module Sus
	class Receive
		CALL_ORIGINAL = Object.new

		def initialize(base, method)
			@base = base
			@method = method
			
			@times = Times.new
			@arguments = nil
			@options = nil
			@block = nil
			@returning = CALL_ORIGINAL
		end
		
		def print(output)
			output.write("receive ", :variable, @method.to_s, :reset)
		end
		
		def with_arguments(predicate)
			@arguments = WithArguments.new(predicate)
			return self
		end
		
		def with_options(predicate)
			@options = WithOptions.new(predicate)
			return self
		end
		
		def with_block(predicate = Be.new(:!=, nil))
			@block = WithBlock.new(predicate)
			return self
		end
		
		def with(*arguments, **options)
			with_arguments(Be.new(:==, arguments)) if arguments.any?
			with_options(Be.new(:==, options)) if options.any?
			return self
		end
		
		def once
			@times = Times.new(Be.new(:==, 1))
			return self
		end
		
		def twice
			@times = Times.new(Be.new(:==, 2))
			return self
		end
		
		def with_call_count(predicate)
			@times = Times.new(predicate)
			return self
		end
		
		def and_return(*returning)
			if returning.size == 1
				@returning = returning.first
			else
				@returning = returning
			end
			return self
		end
		
		def validate(mock, assertions, arguments, options, block)
			return unless @arguments or @options or @block
			
			assertions.nested(self) do |assertions|
				@arguments.call(assertions, arguments) if @arguments
				@options.call(assertions, options) if @options
				@block.call(assertions, block) if @block
			end
		end
		
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
						
						next @returning
					end
				end
				
				if @times
					assertions.defer do
						@times.call(assertions, called)
					end
				end
			end
		end
		
		def call_original?
			@returning == CALL_ORIGINAL
		end
		
		class WithArguments
			def initialize(predicate)
				@predicate = predicate
			end
			
			def print(output)
				output.write("with arguments ", @predicate)
			end
			
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(@predicate)
				end
			end
		end

		class WithOptions
			def initialize(predicate)
				@predicate = predicate
			end
			
			def print(output)
				output.write("with options ", @predicate)
			end
			
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(@predicate)
				end
			end
		end
		
		class WithBlock
			def initialize(predicate)
				@predicate = predicate
			end
			
			def print(output)
				output.write("with block", @predicate)
			end

			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					
					Expect.new(assertions, subject).not.to(Be == nil)
				end
			end
		end

		class Times
			ONCE = Be.new(:==, 1)
			
			def initialize(condition = ONCE)
				@condition = condition
			end
				
			def print(output)
				output.write("with call count ", @condition)
			end

			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(@condition)
				end
			end
		end
	end
	
	class Base
		def receive(method)
			Receive.new(self, method)
		end
	end
end
