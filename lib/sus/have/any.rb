# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Sus
	module Have
		class Any
			def initialize(predicates)
				@predicates = predicates
			end
			
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
