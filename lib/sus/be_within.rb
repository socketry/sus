# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	# Represents a predicate that checks if the subject is within a tolerance of a value.
	class BeWithin
		# Represents a bounded range check.
		class Bounded
			# Initialize a new bounded predicate.
			# @parameter range [Range] The range to check against.
			def initialize(range)
				@range = range
			end
			
			# Print a representation of this predicate.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("be within ", :variable, @range, :reset)
			end
			
			# Evaluate this predicate against a subject.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Object] The subject to evaluate.
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					assertions.assert(@range.include?(subject))
				end
			end
		end
		
		# Initialize a new BeWithin predicate.
		# @parameter tolerance [Numeric] The tolerance value.
		def initialize(tolerance)
			@tolerance = tolerance
		end
		
		# Create a bounded predicate that checks if the subject is within tolerance of a value.
		# @parameter value [Numeric] The value to check against.
		# @returns [Bounded] A new Bounded predicate.
		def of(value)
			tolerance = @tolerance.abs
			
			return Bounded.new(Range.new(value - tolerance, value + tolerance))
		end
		
		# Create a bounded predicate that checks if the subject is within a percentage tolerance of a value.
		# @parameter value [Numeric] The value to check against.
		# @returns [Bounded] A new Bounded predicate.
		def percent_of(value)
			tolerance = Rational(@tolerance, 100)
			
			return Bounded.new(Range.new(value - value * tolerance, value + value * tolerance))
		end
		
		# Print a representation of this predicate.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("be within ", :variable, @tolerance, :reset)
		end
		
		# Evaluate this predicate against a subject.
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Object] The subject to evaluate.
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				assertions.assert(subject < @tolerance, self)
			end
		end
	end
	
	class Base
		# Create a predicate that checks if the subject is within a tolerance or range.
		# @parameter value [Numeric, Range] The tolerance value or range to check against.
		# @returns [BeWithin, BeWithin::Bounded] A BeWithin predicate.
		def be_within(value)
			case value
			when Range
				BeWithin::Bounded.new(value)
			else
				BeWithin.new(value)
			end
		end
	end
end
