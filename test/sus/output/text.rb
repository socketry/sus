# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output"

class InteractiveStringIO < StringIO
	def isatty
		true
	end
	
	def winsize
		[24, 80]
	end
end

describe Sus::Output do
	it "can create xterm output for interactive IO" do
		output = subject.for(InteractiveStringIO.new, {})
		
		expect(output).to be_a(Sus::Output::XTerm)
	end
end

describe Sus::Output::Text do
	let(:io) {StringIO.new}
	let(:output) {subject.new(io)}
	
	it "does not support colors" do
		expect(output.colors?).to be == false
	end
	
	it "can write proc arguments" do
		output.write(->(output){output.write("called")})
		
		expect(io.string).to be == "called"
	end
	
	it "can write inverted assertion prefixes" do
		output.assert(true, false, "expected failure", Sus::Output::Backtrace.new([]))
		output.assert(false, false, "expected failure", Sus::Output::Backtrace.new([]))
		
		expect(io.string).to be(:include?, "expected failure")
	end
	
	it "can write multiline errors with causes" do
		cause = RuntimeError.new("cause")
		
		begin
			raise cause
		rescue
			begin
				raise RuntimeError, "line 1\nline 2"
			rescue RuntimeError => error
				output.error(error, nil)
			end
		end
		
		expect(io.string).to be(:include?, "line 2")
		expect(io.string).to be(:include?, "Caused by")
	end
end
