
require_relative 'context'

module Sus
	module It
		def self.build(parent, description, &block)
			base = Class.new(parent)
			base.extend(It)
			base.description = description
			base.identity = Identity.nested(parent.identity, base.description)
			base.define_method(:call, &block)
			return base
		end
		
		def leaf?
			true
		end
		
		def print(output)
			self.superclass.print(output)
			output.print(" it ", :it, self.description, :reset, " ", self.identity.to_s)
		end
		
		def call(assertions)
			assertions.nested(self) do |assertions|
				instance = self.new(assertions)
				
				instance.around do
					instance.call
				end
			end
		end
	end
	
	module Context
		def it(...)
			add It.build(self, ...)
		end
	end
end
