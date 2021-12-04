
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
end
