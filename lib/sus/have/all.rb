# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Sus
	module Have
		class All
			def initialize(predicates)
				@predicates = predicates
			end
			
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
