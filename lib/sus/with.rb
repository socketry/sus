# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	module With
		extend Context
		
		attr_accessor :subject
		attr_accessor :variables
		
		def self.build(parent, subject, variables, unique: true, &block)
			base = Class.new(parent)
			base.singleton_class.prepend(With)
			base.children = Hash.new
			base.subject = subject
			base.description = subject
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.set_temporary_name("#{self}[#{base.description}]")
			
			base.variables = variables
			
			base.define_method(:description, ->{subject})
			
			variables.each do |key, value|
				base.define_method(key, ->{value})
			end
			
			if block_given?
				base.class_exec(&block)
			end
			
			return base
		end
		
		def print(output)
			self.superclass.print(output)
			
			output.write(
				" with ", :with, self.description, :reset,
				# " ", :variables, self.variables.inspect
			)
		end
	end
	
	module Context
		def with(subject = nil, unique: true, **variables, &block)
			subject ||= variables.inspect
			
			add With.build(self, subject, variables, unique: unique, &block)
		end
	end
end
