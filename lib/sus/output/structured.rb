# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require_relative "null"

module Sus
	module Output
		# Represents a structured JSON output handler for machine-readable output.
		class Structured < Null
			# Create a buffered structured output handler.
			# @parameter io [IO] The IO object to write to.
			# @parameter identity [Identity, nil] Optional identity.
			# @returns [Buffered] A new Buffered instance wrapping a Structured handler.
			def self.buffered(...)
				Buffered.new(self.new(...))
			end
			
			# Initialize a new Structured output handler.
			# @parameter io [IO] The IO object to write to.
			# @parameter identity [Identity, nil] Optional identity.
			def initialize(io, identity = nil)
				@io = io
				@identity = identity
			end
			
			# Output a skip message as JSON.
			# @parameter reason [String] The reason for skipping.
			# @parameter identity [Identity, nil] The identity where the skip occurred.
			def skip(reason, identity)
				inform(reason.to_s, identity)
			end
			
			# Output an informational message as JSON.
			# @parameter message [String, Object] The message to output.
			# @parameter identity [Identity, nil] The identity where the message was generated.
			def inform(message, identity)
				unless message.is_a?(String)
					message = message.inspect
				end
				
				@io.puts(JSON.generate({
					inform: @identity,
					message: {
						text: message,
						location: identity&.to_location,
					}
				}))
				
				@io.flush
			end
		end
	end
end
