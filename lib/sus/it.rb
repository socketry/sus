# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	module It
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
		
		def leaf?
			true
		end
		
		def print(output)
			self.superclass.print(output)
			
			output.write(" it ", :it, self.description, :reset, " ", :identity, self.identity.to_s, :reset)
		end
		
		def to_s
			"it #{description}"
		end
		
		def call(assertions)
			assertions.nested(self, identity: self.identity, isolated: true, measure: true) do |assertions|
				instance = self.new(assertions)
				
				instance.around do
					handle_skip(instance, assertions)
				end
			end
		end
		
		def handle_skip(instance, assertions)
			catch(:skip) do
				return instance.call
			end
		end
	end
	
	module Context
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
		
		def skip_unless_method_defined(method, target)
			unless target.method_defined?(method)
				skip "Method #{method} is not defined in #{target}!"
			end
		end
		
		def skip_unless_constant_defined(constant, target = Object)
			unless target.const_defined?(constant)
				skip "Constant #{constant} is not defined in #{target}!"
			end
		end
		
		def skip_unless_minimum_ruby_version(version)
			unless RUBY_VERSION >= version
				skip "Ruby #{version} is required, but running #{RUBY_VERSION}!"
			end
		end
		
		def skip_if_maximum_ruby_version(version)
			if RUBY_VERSION >= version
				skip "Ruby #{version} is not supported, but running #{RUBY_VERSION}!"
			end
		end
		
		def skip_if_ruby_platform(pattern)
			if match = RUBY_PLATFORM.match(pattern)
				skip "Ruby platform #{match} is not supported!"
			end
		end
	end
end
