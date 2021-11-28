
require_relative 'context'

module Sus
	module With
		extend Context
		
		attr_accessor :subject
		attr_accessor :variables
		
		def self.extended(base)
			base.children = Array.new
		end
		
		def self.build(parent, subject, variables, &block)
			base = Class.new(parent)
			base.extend(With)
			base.subject = subject
			base.description = subject
			base.variables = variables
			
			variables.each do |key, value|
				base.define_method(key, ->{value})
			end
			
			base.class_exec(&block)
			
			return base
		end
		
		def print(output)
			output.print("with ", :with, self.description, :reset, " ", :variables, self.variables.inspect)
		end
		
		def call(assertions = Assertions.new)
			assertions.nested(self) do |assertions|
				self.children.each do |child|
					child.call(assertions)
				end
			end
		end
	end
	
	module Context
		def with(subject, **variables, &block)
			@children << With.build(self, subject, variables, &block)
		end
	end
end
