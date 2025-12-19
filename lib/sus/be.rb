# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	# Represents a predicate matcher that can be used with `expect(...).to be(...)`.
	class Be
		# Represents a logical AND combination of multiple predicates.
		class And
			# Initialize a new AND predicate.
			# @parameter predicates [Array] The predicates to combine with AND logic.
			def initialize(predicates)
				@predicates = predicates
			end
			
			# Print a representation of this predicate.
			# @parameter output [Output] The output target.
			def print(output)
				@predicates.each_with_index do |predicate, index|
					if index > 0
						output.write(" and ", :reset)
					end
					
					predicate.print(output)
				end
			end
			
			# Evaluate this predicate against a subject.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Object] The subject to evaluate.
			def call(assertions, subject)
				@predicates.each do |predicate|
					predicate.call(assertions, subject)
				end
			end
			
			# Combine this predicate with another using AND logic.
			# @parameter other [Object] Another predicate to combine.
			# @returns [And] A new AND predicate.
			def &(other)
				And.new(@predicates + [other])
			end
			
			# Combine this predicate with another using OR logic.
			# @parameter other [Object] Another predicate to combine.
			# @returns [Or] A new OR predicate.
			def |(other)
				Or.new(self, other)
			end
		end
		
		# Represents a logical OR combination of multiple predicates.
		class Or
			# Initialize a new OR predicate.
			# @parameter predicates [Array] The predicates to combine with OR logic.
			def initialize(predicates)
				@predicates = predicates
			end
			
			# Print a representation of this predicate.
			# @parameter output [Output] The output target.
			def print(output)
				@predicates.each_with_index do |predicate, index|
					if index > 0
						output.write(" or ", :reset)
					end
					
					predicate.print(output)
				end
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
						# At least one passed, so we don't care about failures:
						assertions.failed.clear
					else
						# Nothing passed, so we failed:
						assertions.assert(false, "could not find any matching predicate")
					end
				end
			end
			
			# Combine this predicate with another using AND logic.
			# @parameter other [Object] Another predicate to combine.
			# @returns [And] A new AND predicate.
			def &(other)
				And.new(self, other)
			end
			
			# Combine this predicate with another using OR logic.
			# @parameter other [Object] Another predicate to combine.
			# @returns [Or] A new OR predicate.
			def |(other)
				Or.new(@predicates + [other])
			end
		end
		
		# Initialize a new Be predicate.
		# @parameter arguments [Array] The method name and arguments to call on the subject.
		def initialize(*arguments)
			@arguments = arguments
		end
		
		# Combine this predicate with another using OR logic.
		# @parameter other [Object] Another predicate to combine.
		# @returns [Or] A new OR predicate.
		def |(other)
			Or.new([self, other])
		end
		
		# Combine this predicate with others using OR logic.
		# @parameter others [Array] Other predicates to combine.
		# @returns [Or] A new OR predicate.
		def or(*others)
			Or.new([self, *others])
		end
		
		# Combine this predicate with another using AND logic.
		# @parameter other [Object] Another predicate to combine.
		# @returns [And] A new AND predicate.
		def &(other)
			And.new([self, other])
		end
		
		# Combine this predicate with others using AND logic.
		# @parameter others [Array] Other predicates to combine.
		# @returns [And] A new AND predicate.
		def and(*others)
			And.new([self, *others])
		end
		
		# Print a representation of this predicate.
		# @parameter output [Output] The output target.
		def print(output)
			operation, *arguments = *@arguments
			
			output.write("be ", :be, operation.to_s, :reset)
			
			if arguments.any?
				output.write(" ", :variable, arguments.map(&:inspect).join, :reset)
			end
		end
		
		# Evaluate this predicate against a subject.
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Object] The subject to evaluate.
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				assertions.assert(subject.public_send(*@arguments))
			end
		end
		
		class << self
			# Create a predicate that checks equality.
			# @parameter value [Object] The value to compare against.
			# @returns [Be] A new Be predicate.
			def == value
				Be.new(:==, value)
			end
			
			# Create a predicate that checks inequality.
			# @parameter value [Object] The value to compare against.
			# @returns [Be] A new Be predicate.
			def != value
				Be.new(:!=, value)
			end
			
			# Create a predicate that checks if the subject is greater than a value.
			# @parameter value [Object] The value to compare against.
			# @returns [Be] A new Be predicate.
			def > value
				Be.new(:>, value)
			end
			
			# Create a predicate that checks if the subject is greater than or equal to a value.
			# @parameter value [Object] The value to compare against.
			# @returns [Be] A new Be predicate.
			def >= value
				Be.new(:>=, value)
			end
			
			# Create a predicate that checks if the subject is less than a value.
			# @parameter value [Object] The value to compare against.
			# @returns [Be] A new Be predicate.
			def < value
				Be.new(:<, value)
			end
			
			# Create a predicate that checks if the subject is less than or equal to a value.
			# @parameter value [Object] The value to compare against.
			# @returns [Be] A new Be predicate.
			def <= value
				Be.new(:<=, value)
			end
			
			# Create a predicate that checks if the subject matches a pattern.
			# @parameter value [Regexp, Object] The pattern to match against.
			# @returns [Be] A new Be predicate.
			def =~ value
				Be.new(:=~, value)
			end
			
			# Create a predicate that checks case equality.
			# @parameter value [Object] The value to compare against.
			# @returns [Be] A new Be predicate.
			def === value
				Be.new(:===, value)
			end
		end
		
		# A predicate that checks if the subject is nil.
		NIL = Be.new(:nil?)
	end
	
	class Base
		# Create a Be predicate matcher.
		# @parameter arguments [Array] Optional method name and arguments to call on the subject.
		# @returns [Be, Class] A Be predicate if arguments are provided, otherwise the Be class.
		def be(*arguments)
			if arguments.any?
				Be.new(*arguments)
			else
				Be
			end
		end
		
		# Create a predicate that checks if the subject is an instance of a class.
		# @parameter klass [Class] The class to check against.
		# @returns [Be] A new Be predicate.
		def be_a(klass)
			Be.new(:is_a?, klass)
		end
		
		# Create a predicate that checks if the subject is nil.
		# @returns [Be] A Be predicate that checks for nil.
		def be_nil
			Be::NIL
		end
		
		# Create a predicate that checks object identity equality.
		# @parameter other [Object] The object to compare against.
		# @returns [Be] A new Be predicate.
		def be_equal(other)
			Be.new(:equal?, other)
		end
	end
end
