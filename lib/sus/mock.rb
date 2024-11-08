# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require_relative "expect"

module Sus
	class Mock
		def initialize(target)
			@target = target
			@interceptor = Module.new
			
			@target.singleton_class.prepend(@interceptor)
		end
		
		attr :target
		
		def print(output)
			output.write("mock ", :context, @target.inspect)
		end
		
		def clear
			@interceptor.instance_methods.each do |method_name|
				@interceptor.remove_method(method_name)
			end
		end
		
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
		
		def before(method, &hook)
			execution_context = Thread.current

			@interceptor.define_method(method) do |*arguments, **options, &block|
				hook.call(*arguments, **options, &block) if execution_context == Thread.current
				super(*arguments, **options, &block)
			end

			return self
		end

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

	module Mocks
		def after(error = nil)
			super
			
			@mocks&.each_value(&:clear)
		end
		
		def mock(target)
			validate_mock!(target)

			mock = self.mocks[target]

			if block_given?
				yield mock
			end

			return mock
		end
		
		private
		
		MockTargetError = Class.new(StandardError)

		def validate_mock!(target)
			if target.frozen?
				raise MockTargetError, "Cannot mock frozen object #{target.inspect}!"
			end
		end

		def mocks
			@mocks ||= Hash.new{|h,k| h[k] = Mock.new(k)}.compare_by_identity
		end
	end

	class Base
		def mock(target, &block)
			# Pull in the extra functionality:
			self.singleton_class.prepend(Mocks)

			# Redirect the method to the new functionality:
			self.mock(target, &block)
		end
	end
end
