# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "pp"

module Sus
	module Output
		# Provides helpers for representing values in human readable output.
		#
		# Rather than building the full `inspect` representation of a value and then
		# discarding most of it, we stream the pretty-printed output into a buffer
		# that aborts as soon as it exceeds the limit. This avoids materializing huge
		# strings for large subjects (e.g. big arrays or richly inspected instances),
		# which is the same strategy IRB uses when truncating long results.
		module Inspect
			# The default maximum length of an inspected value before it is truncated.
			DEFAULT_LIMIT = 80
			
			# The string appended to a truncated value.
			ELLIPSIS = "…"
			
			# An output target for {PP.singleline_pp} that stops accepting input once
			# it has collected more than `limit` characters. Each individual write is
			# also capped, so a single large chunk (e.g. an object with a custom
			# `inspect`) can't force the whole string to be buffered.
			class LimitedBuffer
				# Raised internally to abort pretty-printing once the limit is reached.
				class Overflow < StandardError
				end
				
				# @parameter limit [Integer] The maximum number of characters to collect.
				def initialize(limit)
					@limit = limit
					@string = String.new
				end
				
				# @attribute [String] The collected output so far (never longer than the limit).
				attr :string
				
				# Append text, truncating and aborting once the limit is exceeded.
				# @parameter text [String] The chunk of output to append.
				def << (text)
					remaining = @limit - @string.length
					
					if text.length >= remaining
						@string << text[0, remaining]
						raise Overflow
					else
						@string << text
					end
					
					return self
				end
			end
			
			# Inspect a value, truncating the result if it exceeds the given limit.
			#
			# @parameter value [Object] The value to inspect.
			# @parameter limit [Integer] The maximum length of the resulting string.
			# @returns [String] The (possibly truncated) inspect representation.
			def self.inspect(value, limit: DEFAULT_LIMIT)
				buffer = LimitedBuffer.new(limit)
				
				begin
					PP.singleline_pp(value, buffer)
					buffer.string
				rescue LimitedBuffer::Overflow
					"#{buffer.string}#{ELLIPSIS}"
				end
			end
			
			# Truncate an already-realised string to the given limit.
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
