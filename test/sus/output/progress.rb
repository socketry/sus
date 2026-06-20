# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/progress"
require "sus/output/text"

describe Sus::Output::Progress do
	let(:io) {StringIO.new}
	let(:output) {Sus::Output::Text.new(io)}
	
	it "can track non-interactive progress" do
		progress = subject.new(output, 4)
		
		expect(progress.current).to be == 0
		expect(progress.total).to be == 4
		expect(progress.remaining).to be == 4
		expect(progress.progress).to be == 0.0
		expect(progress.average_duration).to be_nil
		expect(progress.estimated_remaining_time).to be_nil
		expect(progress.to_s).to be == "0/4 completed"
		
		expect(progress.increment(2)).to be_equal(progress)
		expect(progress.expand(2)).to be_equal(progress)
		
		expect(progress.current).to be == 2
		expect(progress.total).to be == 6
		expect(progress.remaining).to be == 4
		expect(progress.to_s).to be(:include?, "2/6 completed")
	end
	
	it "can render interactive progress" do
		output.define_singleton_method(:interactive?){true}
		
		progress = subject.new(output, 2)
		progress.report(0, "first", :busy)
		progress.increment
		progress.clear
		
		expect(io.string).to be(:include?, "first")
		expect(io.string).to be(:include?, "\e[?7l")
	end
	
	it "formats long durations" do
		progress = subject.new(output, 2)
		
		progress.instance_variable_set(:@start_time, subject.now - 90.0)
		progress.increment
		expect(progress.to_s).to be(:include?, "1m")
		
		progress.instance_variable_set(:@start_time, subject.now - (2 * 60 * 60))
		expect(progress.to_s).to be(:include?, "2h")
		
		progress.instance_variable_set(:@start_time, subject.now - (3 * 24 * 60 * 60))
		expect(progress.to_s).to be(:include?, "3d")
	end
end
