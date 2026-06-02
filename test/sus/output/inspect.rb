# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/inspect"
require "sus/output/text"
require "sus/output/buffered"

describe Sus::Output::Inspect do
	def inspect_string(value, **options)
		Sus::Output::Inspect.buffer(value, **options).string
	end
	
	with ".buffer" do
		it "matches native inspect for common values" do
			[
				[1, 2, 3],
				{"a" => 1, :b => 2},
				"hello\nworld",
				:symbol,
				nil, true, false, 1.5,
				(1..5),
				{"id" => 0, "type" => "Alarm"},
			].each do |value|
				expect(inspect_string(value, limit: 10_000)).to be == value.inspect
			end
		end
		
		it "truncates large values with an ellipsis" do
			big = Array.new(1000) {|i| i}
			result = inspect_string(big)
			expect(result).to be(:end_with?, "…")
			expect(result.length).to be <= (Sus::Output::Inspect::DEFAULT_LIMIT + 1)
		end
		
		it "handles recursive structures" do
			array = [1]
			array << array
			expect(inspect_string(array)).to be == "[1, [...]]"
		end
		
		it "captures the value at call time" do
			array = [1, 2]
			buffer = Sus::Output::Inspect.buffer(array)
			array << 3
			# The buffer captured the value before mutation:
			expect(buffer.string).to be == "[1, 2]"
		end
	end
	
	with ".format" do
		it "emits the value in a single style" do
			buffer = Sus::Output::Buffered.new
			Sus::Output::Inspect.format(buffer, {"key" => 42, :sym => "value"})
			
			styles = buffer.chunks.filter_map {|operation| operation[1] if operation[0] == :write && operation[1].is_a?(Symbol)}.uniq
			expect(styles).to be == [:variable]
		end
		
		it "highlights the ellipsis distinctly when truncating" do
			buffer = Sus::Output::Buffered.new
			Sus::Output::Inspect.format(buffer, Array.new(100) {|i| i}, limit: 20)
			
			styles = buffer.chunks.filter_map {|operation| operation[1] if operation[0] == :write && operation[1].is_a?(Symbol)}.uniq
			expect(styles).to be(:include?, :ellipsis)
		end
	end
	
	with "output#variable" do
		it "writes a truncated representation to the output" do
			buffer = Sus::Output::Buffered.new
			buffer.variable("x" * 200, limit: 20)
			expect(buffer.string).to be(:end_with?, "…")
			expect(buffer.string.length).to be <= 21
		end
	end
end
