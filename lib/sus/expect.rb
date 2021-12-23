
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
			output.write("expect ", :variable, @subject.inspect, :reset, " ")
			
			if @inverted
				output.write(:failed, "to not", :reset)
			else
				output.write(:passed, "to", :reset)
			end
		end
		
		def to(predicate)
			@assertions.nested(self, inverted: @inverted) do |assertions|
				predicate.call(assertions, @subject)
			end
			
			return self
		end
	end
	
	class Base
		def expect(subject = nil, &block)
			if block_given?
				Expect.new(@assertions, block)
			else
				Expect.new(@assertions, subject)
			end
		end
	end
end
