
require_relative 'respond_to'

module Sus
	class Receive
		CALL_ORIGINAL = Object.new

		def initialize(base, method)
			@base = base
			@method = method
			
			@times = Once.new
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

				assertions.defer do
					@times.call(assertions, called)
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

		class Once
			def print(output)
				output.write("once")
			end

			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					Expect.new(assertions, subject).to(Be == 1)
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
