
require_relative 'context'

module Sus
	module Describe
		extend Context
		
		attr_accessor :subject
		
		def self.extended(base)
			base.children = Array.new
		end
		
		def self.build(parent, subject, &block)
			base = Class.new(parent)
			base.extend(Describe)
			base.subject = subject
			base.description = subject.inspect
			base.class_exec(&block)
			return base
		end
		
		def print(output)
			output.print("describe ", :describe, self.description)
		end
	end
	
	module Context
		def describe(...)
			@children << Describe.build(self, ...)
		end
	end
end
