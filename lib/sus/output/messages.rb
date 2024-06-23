# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

module Sus
	# Styled output output.
	module Output
		module Messages
			PASSED_PREFIX = [:passed, "✓ "].freeze
			FAILED_PREFIX = [:failed, "✗ "].freeze
			
			def pass_prefix(orientation)
				if orientation
					PASSED_PREFIX
				else
					FAILED_PREFIX
				end
			end
			
			def fail_prefix(orientation)
				if orientation
					FAILED_PREFIX
				else
					PASSED_PREFIX
				end
			end
			
			# If the orientation is true, and the test passed, then it is a successful outcome.
			# If the orientation is false, and the test failed, then it is a successful outcome.
			# Otherwise, it is a failed outcome.
			# 
			# @parameter condition [Boolean] The result of the test.
			# @parameter orientation [Boolean] The orientation of the assertions.
			# @parameter message [String] The message to display.
			# @parameter backtrace [Array] The backtrace to display.
			def assert(condition, orientation, message, backtrace)
				if condition
					self.puts(:indent, *pass_prefix(orientation), message, backtrace)
				else
					self.puts(:indent, *fail_prefix(orientation), message, backtrace)
				end
			end
			
			def skip_prefix
				"⏸ "
			end
			
			def skip(reason, identity)
				self.puts(:indent, :skipped, skip_prefix, reason)
			end
			
			def error_prefix
				[:errored, "⚠ "]
			end
			
			def error(error, identity, prefix = error_prefix)
				lines = error.message.split(/\r?\n/)
			
				self.puts(:indent, *prefix, error.class, ": ", lines.shift)
				
				lines.each do |line|
					self.puts(:indent, line)
				end
					
				self.write(Output::Backtrace.for(error, identity))
				
				if cause = error.cause
					self.error(cause, identity, ["Caused by ", :errored])
				end
			end
			
			def inform_prefix
				"ℹ "
			end
			
			def inform(message, identity)
				self.puts(:indent, :inform, inform_prefix, message)
			end
		end
	end
end
