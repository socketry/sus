# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/inspect"

describe Sus::Output::Inspect do
	with ".truncate" do
		it "leaves short strings unchanged" do
			expect(Sus::Output::Inspect.truncate("hello")).to be == "hello"
		end
		
		it "truncates long strings and appends an ellipsis" do
			result = Sus::Output::Inspect.truncate("x" * 100, limit: 10)
			expect(result).to be == "#{"x" * 10}…"
			expect(result.length).to be == 11
		end
		
		it "leaves strings at the limit unchanged" do
			expect(Sus::Output::Inspect.truncate("x" * 10, limit: 10)).to be == "x" * 10
		end
	end
	
	with ".inspect" do
		it "inspects short values normally" do
			expect(Sus::Output::Inspect.inspect([1, 2, 3])).to be == "[1, 2, 3]"
		end
		
		it "truncates the inspect of large values" do
			big = Array.new(1000) {|i| i}
			result = Sus::Output::Inspect.inspect(big)
			expect(result).to be(:end_with?, "…")
			expect(result.length).to be <= (Sus::Output::Inspect::DEFAULT_LIMIT + 1)
		end
		
		it "does not materialize the full representation of a huge value" do
			big = Array.new(100_000) {|i| "item-#{i}"}
			result = Sus::Output::Inspect.inspect(big, limit: 40)
			expect(result.length).to be <= 41
			expect(result).to be(:end_with?, "…")
		end
	end
end
