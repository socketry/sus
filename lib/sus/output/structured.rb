# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require_relative "null"

module Sus
	# Styled output output.
	module Output
		class Structured < Null
			def self.buffered(...)
				Buffered.new(self.new(...))
			end
			
			def initialize(io, identity = nil)
				@io = io
				@identity = identity
			end
			
			def skip(reason, identity)
				inform(reason.to_s, identity)
			end
			
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
