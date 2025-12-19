# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Sus
	module Have
		# Represents a predicate that checks if the subject matches any of the given predicates.
		class Any
			# Initialize a new Any predicate.
			# @parameter predicates [Array] The predicates to check.
			def initialize(predicates)
				@predicates = predicates
			end
			
			# Print a representation of this predicate.
			# @parameter output [Output] The output target.
			def print(output)
				first = true
				output.write("have any {")
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
					
					if assertions.passed.any?
						# We don't care about any failures in this case, as long as one of the values passed:
						assertions.failed.clear
					else
						# Nothing passed, so we failed:
						assertions.assert(false, "could not find any matching value")
					end
				end
			end
		end
	end
end
