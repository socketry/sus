# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'context'

module Sus
	module It
		def self.build(parent, description = nil, &block)
			base = Class.new(parent)
			base.extend(It)
			base.description = description
			base.identity = Identity.nested(parent.identity, base.description)
			
			if block_given?
				base.define_method(:call, &block)
			end
			
			return base
		end
		
		def leaf?
			true
		end
		
		def print(output)
			self.superclass.print(output)
			
			if description = self.description
				output.write(" it ", :it, description, :reset, " ", :identity, self.identity.to_s, :reset)
			else
				output.write(" and ", :identity, self.identity.to_s, :reset)
			end
		end
		
		def call(assertions)
			assertions.nested(self, identity: self.identity, isolated: true, measure: true) do |assertions|
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
