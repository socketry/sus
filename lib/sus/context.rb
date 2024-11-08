# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "assertions"
require_relative "identity"

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
		
		# Include an around method to the context class, that invokes the given block before running the test.
		#
		# Before hooks are usually invoked in the order they are defined, i.e. the first defined hook is invoked first.
		#
		# @parameter hook [Proc] The block to execute before each test.
		def before(&hook)
			wrapper = Module.new
			
			wrapper.define_method(:before) do
				super()
				
				instance_exec(&hook)
			end
			
			self.include(wrapper)
		end
		
		# Include an around method to the context class, that invokes the given block after running the test.
		#
		# After hooks are usually invoked in the reverse order they are defined, i.e. the last defined hook is invoked first.
		#
		# @parameter hook [Proc] The block to execute after each test. An `error` argument is passed if the test failed with an exception.
		def after(&hook)
			wrapper = Module.new
			
			wrapper.define_method(:after) do |error|
				instance_exec(error, &hook)
			rescue => error
				raise
			ensure
				super(error)
			end
			
			self.include(wrapper)
		end
		
		# Add an around hook to the context class.
		#
		# Around hooks are called in the reverse order they are defined.
		#
		# The top level `around` implementation invokes before and after hooks.
		#
		# @paremeter block [Proc] The block to execute around each test.
		def around(&block)
			wrapper = Module.new
			
			wrapper.define_method(:around, &block)
			
			self.include(wrapper)
		end
	end
end
