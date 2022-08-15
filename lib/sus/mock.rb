# frozen_string_literal: true

# Copyright, 2022, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'expect'

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
	end

	module Mocks
		def after
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
