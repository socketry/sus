# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

module Sus
	module Output
		# Provides helpers for representing values in human readable output.
		module Inspect
			# The default maximum length of an inspected value before it is truncated.
			DEFAULT_LIMIT = 80
			
			# The string appended to a truncated value.
			ELLIPSIS = "…"
			
			# Inspect a value, truncating the result if it exceeds the given limit.
			#
			# This avoids extremely noisy output when expectations involve large
			# objects (e.g. big arrays or richly inspected instances), while still
			# preserving enough of the value to be recognisable.
			#
			# @parameter value [Object] The value to inspect.
			# @parameter limit [Integer] The maximum length of the resulting string.
			# @returns [String] The (possibly truncated) inspect representation.
			def self.inspect(value, limit: DEFAULT_LIMIT)
				self.truncate(value.inspect, limit: limit)
			end
			
			# Truncate a string to the given limit, appending an ellipsis if needed.
			# @parameter string [String] The string to truncate.
			# @parameter limit [Integer] The maximum length of the resulting string.
			# @returns [String] The (possibly truncated) string.
			def self.truncate(string, limit: DEFAULT_LIMIT)
				if string.length > limit
					"#{string[0, limit]}#{ELLIPSIS}"
				else
					string
				end
			end
		end
	end
end
