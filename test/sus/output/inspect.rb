# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/inspect"
require "sus/output/text"
require "sus/output/buffered"

describe Sus::Output::Inspect do
	with ".inspect" do
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
				expect(Sus::Output::Inspect.inspect(value, limit: 10_000)).to be == value.inspect
			end
		end
		
		it "truncates large values with an ellipsis" do
			big = Array.new(1000) {|i| i}
			result = Sus::Output::Inspect.inspect(big)
			expect(result).to be(:end_with?, "…")
			expect(result.length).to be <= (Sus::Output::Inspect::DEFAULT_LIMIT + 1)
		end
		
		it "does not split multi-line strings (unlike pp)" do
			expect(Sus::Output::Inspect.inspect("a\nb")).to be == "\"a\\nb\""
		end
		
		it "handles recursive structures" do
			array = [1]
			array << array
			expect(Sus::Output::Inspect.inspect(array)).to be == "[1, [...]]"
		end
	end
	
	with ".format" do
		it "emits styled tokens to the output" do
			buffer = Sus::Output::Buffered.new
			Sus::Output::Inspect.format(buffer, {"key" => 42, :sym => "value"})
			
			styles = buffer.chunks.filter_map {|operation| operation[1] if operation[0] == :write && operation[1].is_a?(Symbol)}
			expect(styles).to be(:include?, :literal_string)
			expect(styles).to be(:include?, :literal_number)
			expect(styles).to be(:include?, :literal_symbol)
		end
	end
	
	with ".buffer" do
		it "captures the value at call time" do
			array = [1, 2]
			buffer = Sus::Output::Inspect.buffer(array)
			array << 3
			# The buffer captured the value before mutation:
			expect(buffer.string).to be == "[1, 2]"
		end
	end
end
