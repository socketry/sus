# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/lines"
require "sus/output/status"
require "sus/output/text"

describe Sus::Output::Lines do
	let(:io) {StringIO.new}
	let(:output) {Sus::Output::Text.new(io)}
	let(:lines) {subject.new(output)}
	
	it "can write and clear lines" do
		lines[0] = Sus::Output::Status.new(:free, "idle")
		lines[1] = nil
		
		lines.clear
		
		expect(io.string).to be(:include?, "idle")
		expect(io.string).to be(:include?, "\e[?7l")
		expect(io.string).to be(:include?, "\e[?7h")
	end
	
	it "can update an existing line" do
		lines[0] = Sus::Output::Status.new(:free, "idle")
		io.truncate(0)
		io.rewind
		
		lines[0] = Sus::Output::Status.new(:busy, "busy")
		
		expect(io.string).to be(:include?, "\e[1F\e[K")
		expect(io.string).to be(:include?, "busy")
	end
	
	it "can move back after updating earlier lines" do
		lines[0] = Sus::Output::Status.new(:free, "one")
		lines[1] = Sus::Output::Status.new(:free, "two")
		io.truncate(0)
		io.rewind
		
		lines[0] = Sus::Output::Status.new(:free, "one again")
		
		expect(io.string).to be(:include?, "\e[2F\e[K")
		expect(io.string).to be(:include?, "\e[1E")
	end
end
