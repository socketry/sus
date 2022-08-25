# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'context'

module Sus
	module Context
		def include_context(shared)
			self.class_exec(&shared.block)
		end
	end
end
