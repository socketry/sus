# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	class Be
		class And
			def initialize(predicates)
				@predicates = predicates
			end
			
			def print(output)
				@predicates.each_with_index do |predicate, index|
					if index > 0
						output.write(" and ", :reset)
					end
					
					predicate.print(output)
				end
			end
			
			def call(assertions, subject)
				@predicates.each do |predicate|
					predicate.call(assertions, subject)
				end
			end
			
			def &(other)
				And.new(@predicates + [other])
			end
			
			def |(other)
				Or.new(self, other)
			end
		end
		
		class Or
			def initialize(predicates)
				@predicates = predicates
			end
			
			def print(output)
				@predicates.each_with_index do |predicate, index|
					if index > 0
						output.write(" or ", :reset)
					end
					
					predicate.print(output)
				end
			end
			
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
			
			def &(other)
				And.new(self, other)
			end
			
			def |(other)
				Or.new(@predicates + [other])
			end
		end
		
		def initialize(*arguments)
			@arguments = arguments
		end
		
		def |(other)
			Or.new([self, other])
		end
		
		def or(*others)
			Or.new([self, *others])
		end
		
		def &(other)
			And.new([self, other])
		end
		
		def and(*others)
			And.new([self, *others])
		end
		
		def print(output)
			operation, *arguments = *@arguments
			
			output.write("be ", :be, operation.to_s, :reset)
			
			if arguments.any?
				output.write(" ", :variable, arguments.map(&:inspect).join, :reset)
			end
		end
		
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				assertions.assert(subject.public_send(*@arguments))
			end
		end
		
		class << self
			def == value
				Be.new(:==, value)
			end
			
			def != value
				Be.new(:!=, value)
			end
			
			def > value
				Be.new(:>, value)
			end
			
			def >= value
				Be.new(:>=, value)
			end
			
			def < value
				Be.new(:<, value)
			end
			
			def <= value
				Be.new(:<=, value)
			end
			
			def =~ value
				Be.new(:=~, value)
			end
			
			def === value
				Be.new(:===, value)
			end
		end
		
		NIL = Be.new(:nil?)
	end
	
	class Base
		def be(*arguments)
			if arguments.any?
				Be.new(*arguments)
			else
				Be
			end
		end
		
		def be_a(klass)
			Be.new(:is_a?, klass)
		end
		
		def be_nil
			Be::NIL
		end
		
		def be_equal(other)
			Be.new(:equal?, other)
		end
	end
end
