# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	class BeWithin
		class Bounded
			def initialize(range)
				@range = range
			end
			
			def print(output)
				output.write("be within ", :variable, @range, :reset)
			end
			
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					assertions.assert(@range.include?(subject))
				end
			end
		end
		
		def initialize(tolerance)
			@tolerance = tolerance
		end
		
		def of(value)
			tolerance = @tolerance.abs
			
			return Bounded.new(Range.new(value - tolerance, value + tolerance))
		end
		
		def percent_of(value)
			tolerance = Rational(@tolerance, 100)
			
			return Bounded.new(Range.new(value - value * tolerance, value + value * tolerance))
		end
		
		def print(output)
			output.write("be within ", :variable, @tolerance, :reset)
		end
		
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				assertions.assert(subject < @tolerance, self)
			end
		end
	end
	
	class Base
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
