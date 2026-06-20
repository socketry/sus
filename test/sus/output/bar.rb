# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/bar"
require "sus/output/text"

describe Sus::Output::Bar do
	let(:io) {StringIO.new}
	let(:output) {Sus::Output::Text.new(io)}
	
	def before
		Sus::Output::Bar.register(output)
	end
	
	it "registers progress bar output style" do
		expect(output.styles).to be(:include?, :progress_bar)
	end
	
	it "can print an empty progress bar" do
		bar = subject.new
		bar.print(output)
		
		expect(io.string).to be == (" " * output.width) + "\n"
	end
	
	it "can print progress with a message" do
		bar = subject.new(5, 10, "Loading")
		bar.print(output)
		
		expect(io.string).to be(:start_with?, "Loading: ")
		expect(io.string).to be(:include?, "█")
	end
	
	it "can omit messages that don't fit" do
		bar = subject.new(1, 2, "x" * 100)
		bar.print(output)
		
		expect(io.string).not.to be(:include?, "x")
		expect(io.string).to be(:include?, "█")
	end
	
	it "can update progress" do
		bar = subject.new
		bar.update(1, 2, nil)
		bar.print(output)
		
		expect(io.string).to be(:include?, "█")
	end
end
