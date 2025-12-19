# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	module Output
		# Represents a status indicator for test execution.
		class Status
			# Register status styling with an output handler.
			# @parameter output [Output] The output handler to register with.
			def self.register(output)
				output[:free] ||= output.style(:blue)
				output[:busy] ||= output.style(:orange)
			end
			
			# Initialize a new Status indicator.
			# @parameter state [Symbol] The state (:free or :busy).
			# @parameter context [Object, nil] Optional context to display.
			def initialize(state = :free, context = nil)
				@state = state
				@context = context
			end
			
			# Status indicators for different states.
			INDICATORS = {
				busy: ["◑", "◒", "◐", "◓"],
				free: ["◌"]
			}
			
			# Update the status.
			# @parameter state [Symbol] The new state.
			# @parameter context [Object, nil] Optional new context.
			def update(state, context = nil)
				@state = state
				@context = context
			end
			
			# @returns [String] The current indicator character (animated for busy state).
			def indicator
				if indicators = INDICATORS[@state]
					return indicators[(Time.now.to_f * 10) % indicators.size]
				end
				
				return " "
			end
			
			# Print the status to the output.
			# @parameter output [Output] The output handler.
			def print(output)
				output.write(
					@state, self.indicator, " "
				)
				
				output.write(@context)
				
				output.puts
			end
		end
	end
end
