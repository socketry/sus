# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

module Sus
	class Be
		def initialize(*arguments)
			@arguments = arguments
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
