# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	# Represents a predicate that checks if a block raises an exception.
	class RaiseException
		# Initialize a new RaiseException predicate.
		# @parameter exception_class [Class] The exception class to expect.
		# @parameter message [String, Regexp, Object | Nil] Optional message matcher.
		def initialize(exception_class = Exception, message: nil)
			@exception_class = exception_class
			@message = message
			@predicate = nil
		end
		
		# Add an additional predicate to check on the exception.
		# @parameter predicate [Object] The predicate to apply to the exception.
		# @returns [RaiseException] Returns self for method chaining.
		def and(predicate)
			@predicate = predicate
			return self
		end
		
		# Evaluate this predicate against a subject (block).
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Proc] The block to evaluate.
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
		
		# Print a representation of this predicate.
		# @parameter output [Output] The output target.
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
		# Create a predicate that checks if a block raises an exception.
		# @parameter exception_class [Class] The exception class to expect.
		# @parameter message [String, Regexp, Object | Nil] Optional message matcher.
		# @returns [RaiseException] A new RaiseException predicate.
		def raise_exception(...)
			RaiseException.new(...)
		end
	end
end
