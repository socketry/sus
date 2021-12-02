
require_relative 'context'

module Sus
	module Shared
		attr_accessor :name
		attr_accessor :block
		
		def self.build(name, block)
			base = Class.new
			base.extend(Shared)
			base.name = name
			base.block = block
			
			return base
		end
	end
	
	def self.Shared(name, &block)
		Shared.build(name, block)
	end
	
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
			output.print(
				"it behaves like ", :describe, self.description, :reset,
			)
		end
	end
	
	module Context
		def it_behaves_like(shared)
			add ItBehavesLike.build(self, shared)
		end
	end
end
