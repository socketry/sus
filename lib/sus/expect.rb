# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	# Represents an expectation that can be used with predicates to make assertions.
	class Expect
		# Initialize a new Expect instance.
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Object] The subject to make expectations about.
		# @parameter inverted [Boolean] Whether the expectation is inverted (not).
		# @parameter distinct [Boolean] Whether this expectation should be treated as distinct.
		def initialize(assertions, subject, inverted: false, distinct: false)
			@assertions = assertions
			@subject = subject
			
			# We capture this here, as changes to state may cause the inspect output to change, affecting the output produced by #print.
			@inspect = @subject.inspect
			
			@inverted = inverted
			@distinct = true
		end
		
		# @attribute [Object] The subject being tested.
		attr :subject
		
		# @attribute [Boolean] Whether the expectation is inverted.
		attr :inverted
		
		# Invert this expectation (expect not).
		# @returns [Expect] A new Expect instance with inverted expectation.
		def not
			self.dup.tap do |expect|
				expect.instance_variable_set(:@inverted, !@inverted)
			end
		end
		
		# Print a representation of this expectation.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("expect ", :variable, @inspect, :reset, " ")
			
			if @inverted
				output.write("not to", :reset)
			else
				output.write("to", :reset)
			end
		end
		
		# Apply a predicate to this expectation.
		# @parameter predicate [Object] The predicate to apply.
		# @returns [Expect] Returns self for method chaining.
		def to(predicate)
			# This gets the identity scoped to the current call stack, which ensures that any failures are logged at this point in the code.
			identity = @assertions.identity&.scoped
			
			@assertions.nested(self, inverted: @inverted, identity: identity, distinct: @distinct) do |assertions|
				predicate.call(assertions, @subject)
			end
			
			return self
		end
		
		# Apply another predicate to this expectation (alias for {#to}).
		# @parameter predicate [Object] The predicate to apply.
		# @returns [Expect] Returns self for method chaining.
		def and(predicate)
			return to(predicate)
		end
	end
	
	class Base
		# Create an expectation about a subject or block.
		# @parameter subject [Object, nil] The subject to make expectations about.
		# @yields {...} Optional block to make expectations about.
		# @returns [Expect] A new Expect instance.
		def expect(subject = nil, &block)
			if block_given?
				Expect.new(@__assertions__, block, distinct: true)
			else
				Expect.new(@__assertions__, subject, distinct: true)
			end
		end
	end
end
