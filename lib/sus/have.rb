# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Sus
	module Have
		class Composite
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
		
		class Key
			def initialize(name, predicate = nil)
				@name = name
				@predicate = predicate
			end
			
			def print(output)
				output.write("key ", :variable, @name.inspect, :reset, " ", @predicate, :reset)
			end
			
			def call(assertions, subject)
				assertions.nested(self) do |assertions|
					assertions.assert(subject.key?(@name), "has key")
					@predicate&.call(assertions, subject[@name])
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
				assertions.nested(self) do |assertions|
					assertions.assert(subject.respond_to?(@name), "has attribute")
					@predicate&.call(assertions, subject.send(@name))
				end
			end
		end
	end
	
	class Base
		def have(*predicates)
			Have::Composite.new(predicates)
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
			
			Have::Composite.new(predicates)
		end
		
		def have_attributes(**attributes)
			predicates = attributes.map do |key, value|
				Have::Attribute.new(key, value)
			end
			
			Have::Composite.new(predicates)
		end
	end
end
