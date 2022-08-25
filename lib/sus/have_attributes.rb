# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

module Sus
	class HaveAttributes
		def initialize(attributes)
			@attributes = attributes
		end
		
		def print(output)
			first = true
			output.write("have attributes {")
			@attributes.each do |key, predicate|
				if first
					first = false
				else
					output.write(", ")
				end
				
				output.write(:variable, key.to_s, :reset, " ", predicate, :reset)
			end
			output.write("}")
		end
		
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				@attributes.each do |key, predicate|
					predicate.call(assertions, subject.public_send(key))
				end
			end
		end
	end
	
	class Base
		def have_attributes(...)
			HaveAttributes.new(...)
		end
	end
end
