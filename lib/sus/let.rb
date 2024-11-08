# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	module Context
		def let(name, &block)
			instance_variable = :"@#{name}"
			
			self.define_method(name) do
				if self.instance_variable_defined?(instance_variable)
					return self.instance_variable_get(instance_variable)
				else
					self.instance_variable_set(instance_variable, self.instance_exec(&block))
				end
			end
		end
	end
end
