# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

module Sus
	# Represents a predicate that checks if the subject is truthy.
	module BeTruthy
		# Print a representation of this predicate.
		# @parameter output [Output] The output target.
		def self.print(output)
			output.write("be truthy")
		end
		
		# Evaluate this predicate against a subject.
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Object] The subject to evaluate.
		def self.call(assertions, subject)
			assertions.nested(self) do |assertions|
				assertions.assert(subject, self)
			end
		end
	end
	
	# Represents a predicate that checks if the subject is falsey.
	module BeFalsey
		# Print a representation of this predicate.
		# @parameter output [Output] The output target.
		def self.print(output)
			output.write("be falsey")
		end
		
		# Evaluate this predicate against a subject.
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Object] The subject to evaluate.
		def self.call(assertions, subject)
			assertions.nested(self) do |assertions|
				assertions.assert(!subject, self)
			end
		end
	end
	
	class Base
		# Create a predicate that checks if the subject is truthy.
		# @returns [BeTruthy] A BeTruthy predicate.
		def be_truthy
			BeTruthy
		end
		
		# Create a predicate that checks if the subject is falsey.
		# @returns [BeFalsey] A BeFalsey predicate.
		def be_falsey
			BeFalsey
		end
	end
end
