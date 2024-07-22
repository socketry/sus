# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require_relative 'context'

module Sus
	module Context
		def include_context(shared, *arguments, **options)
			self.class_exec(*arguments, **options, &shared.block)
		end
	end
end
