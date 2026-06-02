# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/variable"
require "sus/output/text"
require "sus/output/buffered"

describe Sus::Output::Variable do
	def inspect_string(value, **options)
		Sus::Output::Variable.buffer(value, **options).string
	end
	
	with ".buffer" do
		it "matches native inspect for common values" do
			[
				[1, 2, 3],
				"hello\nworld",
				:symbol,
				nil, true, false, 1.5,
				(1..5),
			].each do |value|
				expect(inspect_string(value, limit: 10_000)).to be == value.inspect
			end
		end
		
		it "formats hashes consistently" do
			# We use a consistent format regardless of Ruby's version-specific
			# `Hash#inspect` syntax:
			expect(inspect_string({"a" => 1, :b => 2})).to be == "{\"a\" => 1, b: 2}"
		end
		
		it "truncates large values with an ellipsis" do
			big = Array.new(1000){|i| i}
			result = inspect_string(big)
			expect(result).to be(:end_with?, "…")
			expect(result.length).to be <= (Sus::Output::Variable::TRUNCATION_LIMIT + 1)
		end
		
		it "handles recursive structures" do
			array = [1]
			array << array
			expect(inspect_string(array)).to be == "[1, [...]]"
		end
		
		it "truncates objects with long inspect output" do
			object = Object.new
			object.define_singleton_method(:inspect){"#<Big #{"x" * 200}>"}
			expect(inspect_string(object)).to be(:end_with?, "…")
		end
		
		it "falls back when an object's inspect raises" do
			object = Object.new
			object.define_singleton_method(:inspect){raise "boom"}
			expect(inspect_string(object)).to be(:include?, "inspect failed")
		end
		
		it "captures the value at call time" do
			array = [1, 2]
			buffer = Sus::Output::Variable.buffer(array)
			array << 3
			# The buffer captured the value before mutation:
			expect(buffer.string).to be == "[1, 2]"
		end
	end
	
	with ".format" do
		it "emits the value in a single style" do
			buffer = Sus::Output::Buffered.new
			Sus::Output::Variable.format(buffer, {"key" => 42, :sym => "value"})
			
			styles = buffer.chunks.filter_map{|operation| operation[1] if operation[0] == :write && operation[1].is_a?(Symbol)}.uniq
			expect(styles).to be == [:variable]
		end
		
		it "highlights the ellipsis distinctly when truncating" do
			buffer = Sus::Output::Buffered.new
			Sus::Output::Variable.format(buffer, Array.new(100){|i| i}, limit: 20)
			
			styles = buffer.chunks.filter_map{|operation| operation[1] if operation[0] == :write && operation[1].is_a?(Symbol)}.uniq
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
