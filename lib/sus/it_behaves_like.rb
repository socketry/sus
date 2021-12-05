
require_relative 'context'

module Sus
	module ItBehavesLike
		extend Context
		
		attr_accessor :shared
		
		def self.extended(base)
			base.children = Hash.new
		end
		
		def self.build(parent, shared)
			base = Class.new(parent)
			base.extend(ItBehavesLike)
			base.description = shared.name
			base.identity = Identity.nested(parent.identity, base.description, unique: false)
			base.class_exec(&shared.block)
			return base
		end
		
		def print(output)
			self.superclass.print(output)
			output.write(" it behaves like ", :describe, self.description, :reset)
		end
	end
	
	module Context
		def it_behaves_like(shared)
			add ItBehavesLike.build(self, shared)
		end
	end
end
