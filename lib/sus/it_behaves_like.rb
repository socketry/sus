# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	module ItBehavesLike
		extend Context
		
		attr_accessor :shared
		
		def self.build(parent, shared, arguments = nil, unique: false, &block)
			base = Class.new(parent)
			base.singleton_class.prepend(ItBehavesLike)
			base.children = Hash.new
			base.description = shared.name
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.set_temporary_name("#{self}[#{base.description}]")
			
			# User provided block is evaluated first, so that it can provide default behaviour for the shared context:
			if block_given?
				base.class_exec(*arguments, &block)
			end
			
			base.class_exec(*arguments, &shared.block)
			return base
		end
		
		def print(output)
			self.superclass.print(output)
			output.write(" it behaves like ", :describe, self.description, :reset)
		end
	end
	
	module Context
		def it_behaves_like(shared, *arguments, **options, &block)
			add ItBehavesLike.build(self, shared, arguments, **options, &block)
		end
	end
end
