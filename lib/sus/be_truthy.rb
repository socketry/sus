# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

module Sus
	module BeTruthy
		def self.print(output)
			output.write("be truthy")
		end
		
		def self.call(assertions, subject)
			assertions.nested(self) do |assertions|
				assertions.assert(subject, self)
			end
		end
	end
	
	module BeFalsey
		def self.print(output)
			output.write("be falsey")
		end
		
		def self.call(assertions, subject)
			assertions.nested(self) do |assertions|
				assertions.assert(!subject, self)
			end
		end
	end
	
	class Base
		def be_truthy
			BeTruthy
		end
		
		def be_falsey
			BeFalsey
		end
	end
end
