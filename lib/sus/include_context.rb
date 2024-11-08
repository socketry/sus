# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "context"

module Sus
	module Context
		# Include a shared context into the current context, along with any arguments or options.
		#
		# @parameter shared [Sus::Shared] The shared context to include.
		# @parameter arguments [Array] The arguments to pass to the shared context.
		# @parameter options [Hash] The options to pass to the shared context.
		def include_context(shared, *arguments, **options)
			self.class_exec(*arguments, **options, &shared.block)
		end
	end
end
