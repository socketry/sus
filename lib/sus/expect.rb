
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
		def expect(subject = nil, **options, &block)
			if block_given?
				Expect.new(@assertions, block, **options)
			else
				Expect.new(@assertions, subject, **options)
			end
		end
	end
end
