# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	# Represents an individual test case.
	module It
		# Build a new test case class.
		# @parameter parent [Class] The parent context class.
		# @parameter description [String | Nil] Optional description of the test.
		# @parameter unique [Boolean] Whether the identity should be unique.
		# @yields {...} Optional block containing the test code.
		# @returns [Class] A new test case class.
		def self.build(parent, description = nil, unique: true, &block)
			base = Class.new(parent)
			base.extend(It)
			base.description = description
			base.identity = Identity.nested(parent.identity, base.description, unique: unique)
			base.set_temporary_name("#{self}[#{description}]")
			
			if block_given?
				base.define_method(:call, &block)
			end
			
			return base
		end
		
		# @returns [Boolean] Always returns true, as test cases are leaf nodes.
		def leaf?
			true
		end
		
		# Print a representation of this test case.
		# @parameter output [Output] The output target.
		def print(output)
			self.superclass.print(output)
			
			output.write(" it ", :it, self.description, :reset, " ", :identity, self.identity.to_s, :reset)
		end
		
		# @returns [String] A string representation of this test case.
		def to_s
			"it #{description}"
		end
		
		# Execute this test case.
		# @parameter assertions [Assertions] The assertions instance to use.
		def call(assertions)
			assertions.nested(self, identity: self.identity, isolated: true, measure: true) do |assertions|
				instance = self.new(assertions)
				
				instance.around do
					handle_skip(instance, assertions)
				end
			end
		end
		
		# Handle skip logic for the test case.
		# @parameter instance [Base] The test instance.
		# @parameter assertions [Assertions] The assertions instance.
		# @returns [Object] The result of calling the test instance.
		def handle_skip(instance, assertions)
			catch(:skip) do
				return instance.call
			end
		end
	end
	
	module Context
		# Define a new test case.
		# @parameter description [String] The description of the test.
		# @parameter options [Hash] Additional options.
		# @yields {...} The test code.
		def it(...)
			add It.build(self, ...)
		end
	end
	
	class Base
		# Skip the current test with a reason.
		# @parameter reason [String] The reason for skipping the test.
		def skip(reason)
			@__assertions__.skip(reason)
			throw :skip, reason
		end
		
		# Skip the test unless a method is defined on the target.
		# @parameter method [Symbol] The method name to check.
		# @parameter target [Module, Class] The target class or module to check.
		def skip_unless_method_defined(method, target)
			unless target.method_defined?(method)
				skip "Method #{method} is not defined in #{target}!"
			end
		end
		
		# Skip the test unless a constant is defined.
		# @parameter constant [Symbol, String] The constant name to check.
		# @parameter target [Module, Class] The target class or module to check.
		def skip_unless_constant_defined(constant, target = Object)
			unless target.const_defined?(constant)
				skip "Constant #{constant} is not defined in #{target}!"
			end
		end
		
		# Skip the test unless the Ruby version meets the minimum requirement.
		# @parameter version [String] The minimum Ruby version required.
		def skip_unless_minimum_ruby_version(version)
			unless RUBY_VERSION >= version
				skip "Ruby #{version} is required, but running #{RUBY_VERSION}!"
			end
		end
		
		# Skip the test if the Ruby version exceeds the maximum supported version.
		# @parameter version [String] The maximum Ruby version supported.
		def skip_if_maximum_ruby_version(version)
			if RUBY_VERSION >= version
				skip "Ruby #{version} is not supported, but running #{RUBY_VERSION}!"
			end
		end
		
		# Skip the test if the Ruby platform matches the pattern.
		# @parameter pattern [Regexp] The platform pattern to match against.
		def skip_if_ruby_platform(pattern)
			if match = RUBY_PLATFORM.match(pattern)
				skip "Ruby platform #{match} is not supported!"
			end
		end
	end
end
