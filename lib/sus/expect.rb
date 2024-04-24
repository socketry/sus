# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	class Expect
		def initialize(assertions, subject, inverted: false, distinct: false)
			@assertions = assertions
			@subject = subject
			
			# We capture this here, as changes to state may cause the inspect output to change, affecting the output produced by #print.
			@inspect = @subject.inspect
			
			@inverted = inverted
			@distinct = true
		end
		
		attr :subject
		attr :inverted
		
		def not
			self.dup.tap do |expect|
				expect.instance_variable_set(:@inverted, !@inverted)
			end
		end
		
		def print(output)
			output.write("expect ", :variable, @inspect, :reset, " ")
			
			if @inverted
				output.write("not to", :reset)
			else
				output.write("to", :reset)
			end
		end
		
		def to(predicate)
			# This gets the identity scoped to the current call stack, which ensures that any failures are logged at this point in the code.
			identity = @assertions.identity&.scoped
			
			@assertions.nested(self, inverted: @inverted, identity: identity, distinct: @distinct) do |assertions|
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
				Expect.new(@__assertions__, block, distinct: true)
			else
				Expect.new(@__assertions__, subject, distinct: true)
			end
		end
	end
end
