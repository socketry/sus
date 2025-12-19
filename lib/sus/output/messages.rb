# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

module Sus
	module Output
		# Provides message formatting methods for output handlers.
		module Messages
			# The prefix for passed assertions.
			PASSED_PREFIX = [:passed, "✓ "].freeze
			
			# The prefix for failed assertions.
			FAILED_PREFIX = [:failed, "✗ "].freeze
			
			# Get the prefix for a passed assertion based on orientation.
			# @parameter orientation [Boolean] The orientation of the assertions.
			# @returns [Array] The prefix array.
			def pass_prefix(orientation)
				if orientation
					PASSED_PREFIX
				else
					FAILED_PREFIX
				end
			end
			
			# Get the prefix for a failed assertion based on orientation.
			# @parameter orientation [Boolean] The orientation of the assertions.
			# @returns [Array] The prefix array.
			def fail_prefix(orientation)
				if orientation
					FAILED_PREFIX
				else
					PASSED_PREFIX
				end
			end
			
			# Print an assertion result.
			# If the orientation is true, and the test passed, then it is a successful outcome.
			# If the orientation is false, and the test failed, then it is a successful outcome.
			# Otherwise, it is a failed outcome.
			# 
			# @parameter condition [Boolean] The result of the test.
			# @parameter orientation [Boolean] The orientation of the assertions.
			# @parameter message [String] The message to display.
			# @parameter backtrace [Backtrace] The backtrace to display.
			def assert(condition, orientation, message, backtrace)
				if condition
					self.puts(:indent, *pass_prefix(orientation), message, backtrace)
				else
					self.puts(:indent, *fail_prefix(orientation), message, backtrace)
				end
			end
			
			# @returns [String] The prefix for skipped tests.
			def skip_prefix
				"⏸ "
			end
			
			# Print a skip message.
			# @parameter reason [String] The reason for skipping.
			# @parameter identity [Identity, nil] The identity where the skip occurred.
			def skip(reason, identity)
				self.puts(:indent, :skipped, skip_prefix, reason)
			end
			
			# @returns [Array] The prefix for error messages.
			def error_prefix
				[:errored, "⚠ "]
			end
			
			# Print an error message.
			# @parameter error [Exception] The error to display.
			# @parameter identity [Identity, nil] The identity where the error occurred.
			# @parameter prefix [Array] Optional prefix to use.
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
			
			# @returns [String] The prefix for informational messages.
			def inform_prefix
				"ℹ "
			end
			
			# Print an informational message.
			# @parameter message [String] The message to display.
			# @parameter identity [Identity, nil] The identity where the message was generated.
			def inform(message, identity)
				self.puts(:indent, :inform, inform_prefix, message)
			end
		end
	end
end
