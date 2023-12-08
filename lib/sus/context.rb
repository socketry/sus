# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

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
		
		unless respond_to?(:set_temporary_name)
			def set_temporary_name(name)
				# No-op.
			end
			
			def to_s
				(self.description || self.name).to_s
			end
			
			def inspect
				if description = self.description
					"\#<#{self.name || "Context"} #{self.description}>"
				else
					self.name
				end
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
			output.write("context ", :context, self.description, :reset)
		end
		
		def full_name
			output = Output::Buffered.new
			print(output)
			return output.string
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
