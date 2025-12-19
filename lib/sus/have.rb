# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require_relative "have/all"
require_relative "have/any"

module Sus
	# Represents predicates for checking collections and object attributes.
	module Have
		# Represents a predicate that checks if a hash has a specific key.
		class Key
			# Initialize a new Key predicate.
			# @parameter name [Object] The key name to check for.
			# @parameter predicate [Object, nil] Optional predicate to apply to the key's value.
			def initialize(name, predicate = nil)
				@name = name
				@predicate = predicate
			end
			
			# Print a representation of this predicate.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("key ", :variable, @name.inspect, :reset, " ", @predicate, :reset)
			end
			
			# Evaluate this predicate against a subject.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Object] The subject to evaluate (should be a hash).
			def call(assertions, subject)
				# We want to group all the assertions in to a distinct group:
				assertions.nested(self, distinct: true) do |assertions|
					assertions.assert(subject.key?(@name), "has key")
					if @predicate
						Expect.new(assertions, subject[@name]).to(@predicate)
					end
				end
			end
		end
		
		# Represents a predicate that checks if an object has a specific attribute.
		class Attribute
			# Initialize a new Attribute predicate.
			# @parameter name [Symbol, String] The attribute name to check for.
			# @parameter predicate [Object] The predicate to apply to the attribute's value.
			def initialize(name, predicate)
				@name = name
				@predicate = predicate
			end
			
			# Print a representation of this predicate.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("attribute ", :variable, @name.to_s, :reset, " ", @predicate, :reset)
			end
			
			# Evaluate this predicate against a subject.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Object] The subject to evaluate.
			def call(assertions, subject)
				assertions.nested(self, distinct: true) do |assertions|
					assertions.assert(subject.respond_to?(@name), "has attribute")
					if @predicate
						Expect.new(assertions, subject.public_send(@name)).to(@predicate)
					end
				end
			end
		end
		
		# Represents a predicate that checks if a collection has a value matching a predicate.
		class Value
			# Initialize a new Value predicate.
			# @parameter predicate [Object, nil] The predicate to apply to each value in the collection.
			def initialize(predicate)
				@predicate = predicate
			end
			
			# Print a representation of this predicate.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("value ", @predicate, :reset)
			end
			
			# Evaluate this predicate against a subject.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Object] The subject to evaluate (should be enumerable).
			def call(assertions, subject)
				index = 0
				
				subject.each do |value|
					assertions.nested("[#{index}] = #{value.inspect}", distinct: true) do |assertions|
						@predicate&.call(assertions, value)
					end
					
					index += 1
				end
			end
		end
	end
	
	class Base
		# Create a predicate that checks if the subject has all of the given predicates.
		# @parameter predicates [Array] The predicates to check.
		# @returns [Have::All] A Have::All predicate.
		def have(*predicates)
			Have::All.new(predicates)
		end
		
		# Create a predicate that checks if the subject (hash) has the specified keys.
		# @parameter keys [Array] Keys to check for. Can be symbols/strings or hashes with key-predicate pairs.
		# @returns [Have::All] A Have::All predicate.
		def have_keys(*keys)
			predicates = []
			
			keys.each do |key|
				if key.is_a?(Hash)
					key.each do |key, predicate|
						predicates << Have::Key.new(key, predicate)
					end
				else
					predicates << Have::Key.new(key)
				end
			end
			
			Have::All.new(predicates)
		end
		
		# Create a predicate that checks if the subject has the specified attributes with matching values.
		# @parameter attributes [Hash] A hash of attribute names to predicates.
		# @returns [Have::All] A Have::All predicate.
		def have_attributes(**attributes)
			predicates = attributes.map do |key, value|
				Have::Attribute.new(key, value)
			end
			
			Have::All.new(predicates)
		end
		
		# Create a predicate that checks if the subject matches any of the given predicates.
		# @parameter predicates [Array] The predicates to check.
		# @returns [Have::Any] A Have::Any predicate.
		def have_any(*predicates)
			Have::Any.new(predicates)
		end
		
		# Create a predicate that checks if the subject (collection) has any value matching the predicate.
		# @parameter predicate [Object] The predicate to apply to each value.
		# @returns [Have::Any] A Have::Any predicate.
		def have_value(predicate)
			Have::Any.new([Have::Value.new(predicate)])
		end
	end
end
