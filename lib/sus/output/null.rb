# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "messages"

module Sus
	# Styled output output.
	module Output
		class Null
			include Messages
			
			def initialize(nested: true)
				@nested = nested
			end
			
			def buffered
				if @nested
					self
				else
					Buffered.new(nil)
				end
			end
			
			attr :options
			
			def append(buffer)
			end
			
			def each
			end
			
			def indent
			end
			
			def outdent
			end
			
			def indented
				yield
			end
			
			def write(*arguments)
				# Do nothing.
			end
			
			def puts(*arguments)
				# Do nothing.
			end
		end
	end
end
