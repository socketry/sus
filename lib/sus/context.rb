
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
		
		def to_s
			self.description || self.name
		end
		
		def inspect
			if description = self.description
				"\#<#{self.name || "Context"} #{self.description}>"
			else
				self.name
			end
		end
		
		def add(child)
			@children[child.identity] = child
		end
		
		def empty?
			@children.nil? || @children.empty?
		end
		
		def leaf?
			false
		end
		
		def print(output)
			output.write("context ", :context, self.description)
		end
		
		def call(assertions)
			return if self.empty?
			
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
	end
end
