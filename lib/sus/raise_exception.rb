# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	class RaiseException
		def initialize(exception_class = Exception, message: nil)
			@exception_class = exception_class
			@message = message
			@predicate = nil
		end
		
		def and(predicate)
			@predicate = predicate
			return self
		end
		
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				begin
					subject.call
					
					# Didn't throw any exception, so the expectation failed:
					assertions.assert(false, "raised")
				rescue @exception_class => exception
					# Did it have the right message?
					if @message
						Expect.new(assertions, exception.message).to(@message)
					else
						assertions.assert(true, "raised")
					end
					
					@predicate&.call(assertions, exception)
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
			
			if @predicate
				output.write(" and ", @predicate)
			end
		end
	end
	
	class Base
		def raise_exception(...)
			RaiseException.new(...)
		end
	end
end
