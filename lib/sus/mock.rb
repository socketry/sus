# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require_relative "expect"

module Sus
	# Represents a mock object that can intercept and replace method calls on a target object.
	class Mock
		# Initialize a new mock for the given target.
		# @parameter target [Object] The object to mock.
		def initialize(target)
			@target = target
			@interceptor = Module.new
			
			@target.singleton_class.prepend(@interceptor)
		end
		
		# @attribute [Object] The target object being mocked.
		attr :target
		
		# Print a representation of this mock.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("mock ", :context, @target.inspect)
		end
		
		# Clear all mocked methods from the target.
		def clear
			@interceptor.instance_methods.each do |method_name|
				@interceptor.remove_method(method_name)
			end
		end
		
		# Replace a method implementation.
		# @parameter method [Symbol] The method name to replace.
		# @yields {|*arguments, **options, &block| ...} The replacement implementation.
		# @returns [Mock] Returns self for method chaining.
		def replace(method, &hook)
			execution_context = Thread.current
			
			@interceptor.define_method(method) do |*arguments, **options, &block|
				if execution_context == Thread.current
					hook.call(*arguments, **options, &block)
				else
					super(*arguments, **options, &block)
				end
			end
			
			return self
		end
		
		# Add a hook that runs before a method is called.
		# @parameter method [Symbol] The method name to hook.
		# @yields {|*arguments, **options, &block| ...} The hook to execute before the method.
		# @returns [Mock] Returns self for method chaining.
		def before(method, &hook)
			execution_context = Thread.current
			
			@interceptor.define_method(method) do |*arguments, **options, &block|
				hook.call(*arguments, **options, &block) if execution_context == Thread.current
				super(*arguments, **options, &block)
			end
			
			return self
		end
		
		# Add a hook that runs after a method is called.
		# @parameter method [Symbol] The method name to hook.
		# @yields {|result, *arguments, **options, &block| ...} The hook to execute after the method, receiving the result as the first argument.
		# @returns [Mock] Returns self for method chaining.
		def after(method, &hook)
			execution_context = Thread.current
			
			@interceptor.define_method(method) do |*arguments, **options, &block|
				result = super(*arguments, **options, &block)
				hook.call(result, *arguments, **options, &block) if execution_context == Thread.current
				return result
			end
			
			return self
		end
		
		# Wrap a method, yielding the original method as the first argument, so you can call it from within the hook.
		# @parameter method [Symbol] The method name to wrap.
		# @yields {|original, *arguments, **options, &block| ...} The wrapper implementation, receiving the original method as the first argument.
		def wrap(method, &hook)
			execution_context = Thread.current
			
			@interceptor.define_method(method) do |*arguments, **options, &block|
				if execution_context == Thread.current
					original = proc do |*arguments, **options|
						super(*arguments, **options)
					end
					
					hook.call(original, *arguments, **options, &block) 
				else
					super(*arguments, **options, &block)
				end
			end
		end
	end
	
	# Provides mock management functionality for test cases.
	module Mocks
		# Clean up all mocks after the test completes.
		# @parameter error [Exception | Nil] The error that occurred, if any.
		def after(error = nil)
			super
			
			@mocks&.each_value(&:clear)
		end
		
		# Create or access a mock for the given target.
		# @parameter target [Object] The object to mock.
		# @yields {|mock| ...} Optional block to configure the mock.
		# @returns [Mock] The mock instance for the target.
		def mock(target)
			validate_mock!(target)
			
			mock = self.mocks[target]
			
			if block_given?
				yield mock
			end
			
			return mock
		end
		
		private
		
		# Error raised when attempting to mock a frozen object.
		MockTargetError = Class.new(StandardError)
		
		# Validate that the target can be mocked.
		# @parameter target [Object] The object to validate.
		# @raises [MockTargetError] If the target is frozen.
		def validate_mock!(target)
			if target.frozen?
				raise MockTargetError, "Cannot mock frozen object #{target.inspect}!"
			end
		end
		
		# Get the mocks hash, creating it if necessary.
		# @returns [Hash] A hash mapping targets to their mock instances.
		def mocks
			@mocks ||= Hash.new{|h,k| h[k] = Mock.new(k)}.compare_by_identity
		end
	end
	
	class Base
		# Create or access a mock for the given target.
		# @parameter target [Object] The object to mock.
		# @yields {|mock| ...} Optional block to configure the mock.
		# @returns [Mock] The mock instance for the target.
		def mock(target, &block)
			# Pull in the extra functionality:
			self.singleton_class.prepend(Mocks)
			
			# Redirect the method to the new functionality:
			self.mock(target, &block)
		end
	end
end
