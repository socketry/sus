# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

module Sus
	class Expect
		def initialize(assertions, subject, inverted: false, buffered: false)
			@assertions = assertions
			@subject = subject
			@inverted = inverted
			@buffered = buffered
		end
		
		attr :subject
		attr :inverted
		attr :assertions
		
		def not
			self.dup.tap do |expect|
				expect.instance_variable_set(:@inverted, !@inverted)
			end
		end
		
		def print(output)
			output.write("expect ", :variable, @subject.inspect, :reset, " ")
			
			if @inverted
				output.write("to not", :reset)
			else
				output.write("to", :reset)
			end
		end
		
		def to(predicate)
			# This gets the identity scoped to the current call stack, which ensures that any failures are logged at this point in the code.
			identity = @assertions.identity&.scoped
			
			@assertions.nested(self, inverted: @inverted, buffered: @buffered, identity: identity) do |assertions|
				predicate.call(assertions, @subject)
			end
			
			return self
		end
		
		def and(predicate)
			return to(predicate)
		end
	end
	
	class Base
		def expect(subject = nil, &block)
			if block_given?
				Expect.new(@__assertions__, block, buffered: true)
			else
				Expect.new(@__assertions__, subject, buffered: true)
			end
		end
	end
end
