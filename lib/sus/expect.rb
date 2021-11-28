
module Sus
	class Expect
		def initialize(assertions, subject)
			@assertions = assertions
			@subject = subject
		end
		
		def to(predicate)
			predicate.call(@assertions.nested, @subject)
			
			return self
		end
		
		def to_not(predicate)
			predicate.call(@assertions.nested(inverted: true), @subject)
			
			return self
		end
		
		def to_throw(...)
			ThrowException.new(...).call(@assertions, @subject)
			
			return self
		end
	end
	
	class Truthy
		def call(target)
			!!target
		end
		
		def print(output)
			output << "to be truthy"
		end
	end
	
	class Falsey
		def call(target)
			!target
		end
		
		def print(output)
			output << "to be falsey"
		end
	end
	
	class ThrowException
		def initialize(exception_class, message = nil)
			@exception_class = exception_class
			@message = message
		end
		
		def call(assertions, value)
			begin
				value.call
				
				# Didn't throw any exception, so the expectation failed:
				assertions.assert(false, self)
			rescue => exception
				# Did we throw the right kind of exception?
				if exception.is_a?(@exception_class)
					# Did it have the right message?
					if @message
						assertions.assert(@message === exception.message
					else
						assertions.assert(true, self)
					end
				else
					raise
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
