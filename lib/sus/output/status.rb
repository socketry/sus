# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	module Output
		class Status
			def self.register(output)
				output[:free] ||= output.style(:blue)
				output[:busy] ||= output.style(:orange)
			end
			
			def initialize(state = :free, context = nil)
				@state = state
				@context = context
			end
			
			INDICATORS = {
				busy: ["◑", "◒", "◐", "◓"],
				free: ["◌"]
			}
			
			def update(state, context = nil)
				@state = state
				@context = context
			end
			
			def indicator
				if indicators = INDICATORS[@state]
					return indicators[(Time.now.to_f * 10) % indicators.size]
				end
				
				return " "
			end
			
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
