module Sus
	class RaiseException
		def initialize(exception_class = nil, message: nil)
			@exception_class = exception_class
			@message = message
		end
		
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				begin
					subject.call
					
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
			output.write("raise exception")
			
			if @exception_class
				output.write(" ", :variable, @exception_class, :reset)
			end
			
			if @message
				output.write(" with message ", :variable, @message, :reset)
			end
		end
	end
	
	class Base
		def raise_exception(...)
			RaiseException.new(...)
		end
	end
end
