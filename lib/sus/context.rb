# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "assertions"
require_relative "identity"

module Sus
	# Represents a test context that can contain nested tests and other contexts.
	module Context
		# @attribute [Identity, nil] The identity of this context.
		attr_accessor :identity
		
		# @attribute [String, nil] The description of this context.
		attr_accessor :description
		
		# @attribute [Hash] The child contexts and tests.
		attr_accessor :children
		
		# Called when this module is extended.
		# @parameter base [Class] The class being extended.
		def self.extended(base)
			base.children = Hash.new
		end
		
		unless respond_to?(:set_temporary_name)
			# Set a temporary name for this context.
			# @parameter name [String] The temporary name.
			def set_temporary_name(name)
				# No-op.
			end
			
			# @returns [String] A string representation of this context.
			def to_s
				(self.description || self.name).to_s
			end
			
			# @returns [String] An inspect representation of this context.
			def inspect
				if description = self.description
					"\#<#{self.name || "Context"} #{self.description}>"
				else
					self.name
				end
			end
		end
		
		# Add a child context or test to this context.
		# @parameter child [Object] The child to add.
		def add(child)
			@children[child.identity] = child
		end
		
		# @returns [Boolean] Whether this context has no children.
		def empty?
			@children.nil? || @children.empty?
		end
		
		# @returns [Boolean] Always returns false, as contexts are not leaf nodes.
		def leaf?
			false
		end
		
		# Print a representation of this context.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("context ", :context, self.description, :reset)
		end
		
		# @returns [String] The full name of this context.
		def full_name
			output = Output::Buffered.new
			print(output)
			return output.string
		end
		
		# Execute all child contexts and tests.
		# @parameter assertions [Assertions] The assertions instance to use.
		def call(assertions)
			return if self.empty?
			
			assertions.nested(self) do |assertions|
				self.children.each do |identity, child|
					child.call(assertions)
				end
			end
		end
		
		# Iterate over all leaf nodes (test cases) in this context.
		# @yields {|test| ...} Each test case.
		def each(&block)
			self.children.each do |identity, child|
				if child.leaf?
					yield child
				else
					child.each(&block)
				end
			end
		end
		
		# Include a before hook to the context class, that invokes the given block before running each test.
		#
		# Before hooks are usually invoked in the order they are defined, i.e. the first defined hook is invoked first.
		#
		# @yields {...} The block to execute before each test.
		def before(&hook)
			wrapper = Module.new
			
			wrapper.define_method(:before) do
				super()
				
				instance_exec(&hook)
			end
			
			self.include(wrapper)
		end
		
		# Include an after hook to the context class, that invokes the given block after running each test.
		#
		# After hooks are usually invoked in the reverse order they are defined, i.e. the last defined hook is invoked first.
		#
		# @yields {|error| ...} The block to execute after each test. An `error` argument is passed if the test failed with an exception.
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
		# @yields {|&block| ...} The block to execute around each test.
		def around(&block)
			wrapper = Module.new
			
			wrapper.define_method(:around, &block)
			
			self.include(wrapper)
		end
	end
end
