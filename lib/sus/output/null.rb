# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require_relative "messages"

module Sus
	module Output
		# Represents a null output handler that discards all output.
		class Null
			include Messages
			
			# Initialize a new Null output handler.
			def initialize
			end
			
			# Create a buffered output handler.
			# @returns [Buffered] A new Buffered instance.
			def buffered
				Buffered.new(nil)
			end
			
			# @attribute [Hash, nil] Optional options (unused).
			attr :options
			
			# Append chunks from a buffer (no-op).
			# @parameter buffer [Buffered] The buffer to append from.
			def append(buffer)
			end
			
			# Increase indentation (no-op).
			def indent
			end
			
			# Decrease indentation (no-op).
			def outdent
			end
			
			# Execute a block with indentation (no-op, just yields).
			# @yields {...} The block to execute.
			def indented
				yield
			end
			
			# Write output (no-op).
			# @parameter arguments [Array] The arguments to write.
			def write(*arguments)
				# Do nothing.
			end
			
			# Write output followed by a newline (no-op).
			# @parameter arguments [Array] The arguments to write.
			def puts(*arguments)
				# Do nothing.
			end
		end
	end
end
