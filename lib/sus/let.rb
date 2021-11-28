
require_relative 'context'

module Sus
	module Context
		def let(name, &block)
			ivar = :"@#{name}"
			
			self.define_method(name) do
				if value = self.instance_variable_get(ivar)
					return value
				else
					self.instance_variable_set(ivar, block.call)
				end
			end
		end
	end
end
