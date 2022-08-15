
module Sus
	class Be
		def initialize(*arguments)
			@arguments = arguments
		end
		
		def print(output)
			output.write("be ", :be, *@arguments.join(" "))
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
	end
end
