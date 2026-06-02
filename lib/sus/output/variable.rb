# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "buffered"

module Sus
	module Output
		# Provides a compact, truncated representation of values for output.
		#
		# Rather than building a full `inspect` string and then truncating it, we walk
		# the value and stream tokens directly into an output, aborting as soon as a
		# character budget is exhausted. This means we never materialize the full
		# representation of a large subject (e.g. a big array or richly inspected
		# instance).
		#
		# Containers (arrays and hashes) are formatted directly so we can recurse with
		# the budget; leaf values delegate to native `inspect` so their formatting
		# exactly matches Ruby. The value itself is emitted in a single style (matching
		# the rest of sus's output), and only the truncation ellipsis is highlighted
		# distinctly so it's clear where output was cut.
		module Variable
			# The maximum length of an inspected value before it is truncated. Override
			# it with the `SUS_OUTPUT_VARIABLE_TRUNCATION_LIMIT` environment variable; a
			# value of `0` (or `nil`) disables truncation entirely.
			TRUNCATION_LIMIT = ENV.fetch("SUS_OUTPUT_VARIABLE_TRUNCATION_LIMIT", 100).then do |value|
				value = Integer(value)
				value.zero? ? nil : value
			end
			
			# The string appended to a truncated value.
			ELLIPSIS = "…"
			
			# Walks a value and emits styled tokens to an output, aborting once the
			# character budget is exhausted.
			class Formatter
				# Raised internally to abort formatting once the limit is reached.
				class Truncated < StandardError
				end
				
				# @parameter output [Output] The output target to write tokens to.
				# @parameter limit [Integer] The maximum number of characters to emit.
				def initialize(output, limit:)
					@output = output
					@remaining = limit
					@seen = nil
				end
				
				# Emit a token, truncating and aborting once the budget is exceeded.
				# @parameter text [String] The token text to emit.
				# @parameter style [Symbol, nil] The style symbol to wrap the token in.
				def emit(text, style = :variable)
					truncated = false
					
					if text.length > @remaining
						text = text[0, @remaining]
						truncated = true
					end
					
					@remaining -= text.length
					
					if style
						@output.write(style, text, :reset)
					else
						@output.write(text)
					end
					
					raise Truncated if truncated
				end
				
				# Format a value, emitting styled tokens to the output.
				# @parameter value [Object] The value to format.
				def format(value)
					case value
					when String
						# Inspect only a prefix so we never escape a huge string:
						slice = value.length > @remaining ? value[0, @remaining] : value
						emit(slice.inspect)
					when Array
						format_array(value)
					when Hash
						format_hash(value)
					else
						format_object(value)
					end
				end
				
				private
				
				def format_array(array)
					if @seen&.key?(array.object_id)
						return emit("[...]")
					end
					
					(@seen ||= {})[array.object_id] = true
					
					begin
						emit("[")
						array.each_with_index do |element, index|
							emit(", ") if index > 0
							format(element)
						end
						emit("]")
					ensure
						@seen.delete(array.object_id)
					end
				end
				
				def format_hash(hash)
					if @seen&.key?(hash.object_id)
						return emit("{...}")
					end
					
					(@seen ||= {})[hash.object_id] = true
					
					begin
						emit("{")
						first = true
						hash.each do |key, value|
							emit(", ") unless first
							first = false
							
							if key.is_a?(Symbol)
								# Ruby's label form for symbol keys, e.g. `key: value`:
								emit("#{key.inspect.delete_prefix(":")}: ")
							else
								format(key)
								emit(" => ")
							end
							
							format(value)
						end
						emit("}")
					ensure
						@seen.delete(hash.object_id)
					end
				end
				
				def format_object(value)
					emit(value.inspect)
				rescue Truncated
					raise
				rescue => error
					emit("#<#{value.class} (inspect failed: #{error.class})>")
				end
			end
			
			# Format a value into the given output, truncating at the limit.
			# @parameter output [Output] The output target.
			# @parameter value [Object] The value to format.
			# @parameter limit [Integer] The maximum length of the representation.
			def self.format(output, value, limit: TRUNCATION_LIMIT)
				# With no limit, the formatter would produce exactly `value.inspect`, so
				# we can skip walking the value and emit it directly:
				unless limit
					return output.write(:variable, value.inspect, :reset)
				end
				
				formatter = Formatter.new(output, limit: limit)
				
				begin
					formatter.format(value)
				rescue Formatter::Truncated
					output.write(:ellipsis, ELLIPSIS, :reset)
				end
			end
			
			# Capture a value's representation into a buffer, resolving the value
			# immediately, but deferring colour resolution until the buffer is replayed
			# into a real output.
			# @parameter value [Object] The value to capture.
			# @parameter limit [Integer] The maximum length of the representation.
			# @returns [Buffered] A buffer containing the captured representation.
			def self.buffer(value, limit: TRUNCATION_LIMIT)
				buffer = Buffered.new
				self.format(buffer, value, limit: limit)
				return buffer
			end
		end
	end
end
