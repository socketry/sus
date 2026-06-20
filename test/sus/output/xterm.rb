# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/xterm"

class WindowedStringIO < StringIO
	def winsize
		[30, 120]
	end
end

describe Sus::Output::XTerm do
	let(:io) {WindowedStringIO.new}
	let(:output) {subject.new(io)}
	
	it "supports colors" do
		expect(output.colors?).to be == true
	end
	
	it "uses terminal size" do
		expect(output.size).to be == [30, 120]
	end
	
	it "can create styles" do
		expect(output.style(:red, :white, :bold, 4)).to be == "\e[31;47;1;4m"
	end
	
	it "can reset styles" do
		expect(output.reset).to be == "\e[0m"
	end
end
