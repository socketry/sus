
module Sus
	class Be
		def initialize(*arguments)
			@arguments = arguments
		end
		
		def print(output)
			operation, *arguments = *@arguments
			
			output.write("be ", :be, operation.to_s, :reset, " ", :variable, arguments.map(&:inspect).join, :reset)
		end
		
		def call(assertions, subject)
			assertions.assert(subject.public_send(*@arguments), self)
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
	end
end
