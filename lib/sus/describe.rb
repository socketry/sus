# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	module Describe
		extend Context
		
		attr_accessor :subject
		
		def self.build(parent, subject, unique: true, &block)
			base = Class.new(parent)
			base.singleton_class.prepend(Describe)
			base.children = Hash.new
			base.subject = subject
			base.description = subject.to_s
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.set_temporary_name("#{self}[#{base.description}]")
			
			base.define_method(:subject, ->{subject})
			
			if block_given?
				base.class_exec(&block)
			end
			
			return base
		end
		
		def print(output)
			output.write(
				"describe ", :describe, self.description, :reset,
				# " ", self.identity.to_s
			)
		end
	end
	
	module Context
		def describe(subject, **options, &block)
			add Describe.build(self, subject, **options, &block)
		end
	end
end
