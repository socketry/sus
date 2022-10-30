# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'context'

module Sus
	module ItBehavesLike
		extend Context
		
		attr_accessor :shared
		
		def self.build(parent, shared, unique: false, &block)
			base = Class.new(parent)
			base.singleton_class.prepend(ItBehavesLike)
			base.children = Hash.new
			base.description = shared.name
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)

			# User provided block is evaluated first, so that it can provide default behaviour for the shared context:
			if block_given?
				base.class_exec(&block)
			end

			base.class_exec(&shared.block)
			return base
		end
		
		def print(output)
			self.superclass.print(output)
			output.write(" it behaves like ", :describe, self.description, :reset)
		end
	end
	
	module Context
		def it_behaves_like(shared, **options, &block)
			add ItBehavesLike.build(self, shared, **options, &block)
		end
	end
end
