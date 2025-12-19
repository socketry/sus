# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Sus
	module Have
		# Represents a predicate that checks if the subject matches all of the given predicates.
		class All
			# Initialize a new All predicate.
			# @parameter predicates [Array] The predicates to check.
			def initialize(predicates)
				@predicates = predicates
			end
			
			# Print a representation of this predicate.
			# @parameter output [Output] The output target.
			def print(output)
				first = true
				output.write("have {")
				@predicates.each do |predicate|
					if first
						first = false
					else
						output.write(", ")
					end
					
					output.write(predicate)
				end
				output.write("}")
			end
			
			# Evaluate this predicate against a subject.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Object] The subject to evaluate.
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					@predicates.each do |predicate|
						predicate.call(assertions, subject)
					end
				end
			end
		end
	end
end
