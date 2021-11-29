
module Sus
	class Expect
		def initialize(assertions, subject)
			@assertions = assertions
			@subject = subject
			@inverted = false
		end
		
		def not
			self.dup.tap do |expect|
				expect.instance_variable_set(:@inverted, !@inverted)
			end
		end
		
		def print(output)
			output.print("expect ", :variable, @subject, :reset, " ")
			
			if @inverted
				output.print(:failed, "to not", :reset)
			else
				output.print(:passed, "to", :reset)
			end
		end
		
		def to(predicate)
			@assertions.nested(self, inverted: @inverted) do |assertions|
				predicate.call(assertions, @subject)
			end
			
			return self
		end
		
		def to_throw(...)
			predicate = ThrowException.new(...)
			
			@assertions.nested(self, inverted: @inverted) do |assertions|
				predicate.call(assertions, @subject)
			end
			
			return self
		end
	end
	
	class Base
		def expect(subject)
			Expect.new(@assertions, subject)
		end
	end
	
	class ThrowException
		def initialize(exception_class, message = nil)
			@exception_class = exception_class
			@message = message
		end
		
		def call(assertions, value)
			assertions.nested(self) do |assertions|
				begin
					value.call
					
					# Didn't throw any exception, so the expectation failed:
					assertions.assert(false, self)
				rescue => exception
					# Did we throw the right kind of exception?
					if exception.is_a?(@exception_class)
						# Did it have the right message?
						if @message
							assertions.assert(@message === exception.message)
						else
							assertions.assert(true, self)
						end
					else
						raise
					end
				end
			end
		end
		
		def print(output)
			output << "throw exception " << output.style(@exception_class, :variable)
			
			if @message
				output << "with message " << output.style(@message, :variable)
			end
		end
	end
end
