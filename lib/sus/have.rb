# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require_relative "have/all"
require_relative "have/any"

module Sus
	module Have
		class Key
			def initialize(name, predicate = nil)
				@name = name
				@predicate = predicate
			end
			
			def print(output)
				output.write("key ", :variable, @name.inspect, :reset, " ", @predicate, :reset)
			end
			
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
		
		class Attribute
			def initialize(name, predicate)
				@name = name
				@predicate = predicate
			end
			
			def print(output)
				output.write("attribute ", :variable, @name.to_s, :reset, " ", @predicate, :reset)
			end
			
			def call(assertions, subject)
				assertions.nested(self, distinct: true) do |assertions|
					assertions.assert(subject.respond_to?(@name), "has attribute")
					if @predicate
						Expect.new(assertions, subject.public_send(@name)).to(@predicate)
					end
				end
			end
		end
		
		class Value
			def initialize(predicate)
				@predicate = predicate
			end
			
			def print(output)
				output.write("value ", @predicate, :reset)
			end
			
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
		def have(*predicates)
			Have::All.new(predicates)
		end
		
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
		
		def have_attributes(**attributes)
			predicates = attributes.map do |key, value|
				Have::Attribute.new(key, value)
			end
			
			Have::All.new(predicates)
		end
		
		def have_any(*predicates)
			Have::Any.new(predicates)
		end
		
		def have_value(predicate)
			Have::Any.new([Have::Value.new(predicate)])
		end
	end
end
