# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

module Sus
	class Expect
		def initialize(assertions, subject, inverted: false)
			@assertions = assertions
			@subject = subject
			@inverted = inverted
		end

		attr :subject
		attr :inverted
		
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
			@assertions.nested(self, inverted: @inverted) do |assertions|
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
				Expect.new(@__assertions__, block)
			else
				Expect.new(@__assertions__, subject)
			end
		end
	end
end
