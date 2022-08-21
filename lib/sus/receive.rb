
require_relative 'respond_to'

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
			output.write("receive ", :variable, @method.to_s, :reset, " ")
		end
		
		def with_arguments(*arguments)
			@arguments = WithArguments.new(arguments)
			return self
		end

		def with_options(*options)
			@options = WithOptions.new(options)
			return self
		end

		def with_block
			@block = WithBlock.new
			return self
		end

		def once
			@times = Times.new(Be.new(:==, 1))
		end
		
		def twice
			@times = Times.new(Be.new(:==, 2))
		end
		
		def with_call_count(predicate)
			@times = Times.new(predicate)
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
			@arguments.call(assertions, arguments) if @arguments
			@options.call(assertions, options) if @options
			@block.call(assertions, block) if @block
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
			def initialize(arguments)
				@arguments = arguments
			end
			
			def print(output)
				output.write("with arguments ", :variable, @arguments.inspect)
			end
			
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(Be == @arguments)
				end
			end
		end

		class WithOptions
			def initialize(options)
				@options = options
			end
			
			def print(output)
				output.write("with options ", :variable, @options.inspect)
			end
			
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(Be.new(:include?, @options))
				end
			end
		end
		
		class WithBlock
			def print(output)
				output.write("with block")
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
