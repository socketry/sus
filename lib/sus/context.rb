
require_relative 'assertions'
require_relative 'identity'

module Sus
	module Context
		attr_accessor :identity
		attr_accessor :description
		attr_accessor :children
		
		def self.extended(base)
			base.children = Hash.new
		end
		
		def inspect
			"\#<#{self.description}>"
		end
		
		def add(child)
			@children[child.identity] = child
		end
		
		def leaf?
			false
		end
		
		def print(output)
			output.print("context ", :context, self.description)
		end
		
		def call(assertions)
			assertions.nested(self) do |assertions|
				self.children.each do |identity, child|
					child.call(assertions)
				end
			end
		end
		
		def each(&block)
			self.children.each do |identity, child|
				if child.leaf?
					yield child
				else
					child.each(&block)
				end
			end
		end
		
		def lookup(identity)
			context = self
			
			identity.each do |key|
				return unless context = context.children[key]
			end
			
			return context
		end
	end
	
	class Base
		def initialize(assertions)
			@assertions = assertions
		end
		
		def before
		end
		
		def after
		end
		
		def around
			self.before
			
			return yield
		ensure
			self.after
		end
		
		def assert(...)
			@assertions.assert(...)
		end
		
		def refute(...)
			@assertions.refute(...)
		end
		
		def expect(subject)
			Expect.new(subject)
		end
	end
end
