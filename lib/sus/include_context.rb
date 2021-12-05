
require_relative 'context'

module Sus
	module Context
		def include_context(shared)
			self.class_exec(&shared.block)
		end
	end
end
