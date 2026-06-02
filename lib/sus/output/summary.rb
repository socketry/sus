# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "json"

require_relative "null"

module Sus
	module Output
		# A machine-readable, failure-focused output adapter.
		#
		# Unlike the human-oriented text output, this emits a single JSON document
		# summarising the run: aggregate counts plus the details of every failure and
		# error (passing tests are reported only as a count). It's intended for tools
		# and language models that need to extract failures reliably rather than parse
		# prose.
		#
		# This is distinct from {Structured}, which streams per-event JSON for the
		# test runner/RPC (e.g. sus-vscode).
		class Summary < Null
			# Initialize a new Summary output handler.
			# @parameter io [IO] The IO object to write the JSON document to.
			def initialize(io = $stdout)
				super()
				@io = io
			end
			
			# Emit the JSON summary document for the run.
			# @parameter assertions [Assertions] The top-level assertions instance.
			# @parameter clock [Clock] The clock measuring the run duration.
			# @parameter partial [Boolean] Whether only a subset of tests was run.
			def summary(assertions, clock:, partial: false)
				document = {
					success: assertions.failed.empty? && assertions.errored.empty?,
					passed: assertions.passed.size,
					failed: assertions.failed.size,
					errored: assertions.errored.size,
					skipped: assertions.skipped.size,
					total: assertions.total,
					assertions: assertions.count,
					duration: clock.duration,
					partial: partial,
					failures: assertions.failed.map{|assertion| detail(assertion)},
					errors: assertions.errored.map{|assertion| detail(assertion)},
				}
				
				@io.puts(::JSON.generate(document))
				@io.flush
			end
			
			private
			
			# Build the structured detail for a single failed or errored assertion.
			def detail(assertion)
				{
					test: assertion.identity&.to_s,
					location: assertion.identity&.to_location,
					detail: assertion.output.string.strip,
				}
			end
		end
	end
end
