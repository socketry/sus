# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require "sus/output/status"

describe Sus::Output::Backtrace do
	let(:identity) {Sus::Identity.current}
	let(:backtrace) {subject.new(caller_locations)}
	
	# The root path of stack paths. This is similar to __dir__ but not exactly the same, as JRuby computes `__dir__` as an absolute path even when it doesn't make sense.
	let(:backtrace_path_root) {File.dirname(__FILE__)}
	
	it "has several frames" do
		expect(backtrace.stack).to have_attributes(size: be >= 1)
	end
	
	it "can extract native backtrace locations" do
		error = RuntimeError.new("boom")
		error.set_backtrace(caller)
		
		begin
			raise error
		rescue RuntimeError => error
			expect(subject.extract_stack(error).first).to respond_to(:path)
		end
	end
	
	with "a limit of one" do
		it "has exactly one frame" do
			expect(backtrace.filter(limit: 1)).to have_attributes(size: be == 1)
		end
	end
	
	with "a root directory" do
		it "has frames in the root directory" do
			stack = backtrace.filter(root: identity.path)
			expect(stack.size).to be >= 1
			expect(stack.last.path).to be(:start_with?, identity.path)
		end
	end
	
	it "can print multiple frames" do
		output = Sus::Output.buffered
		backtrace.print(output)
		
		expect(output.string).to be(:include?, __FILE__)
	end
	
	it "can filter matching frames after the preface" do
		stack = [
			Sus::Output::Backtrace::Location.new("/tmp/one.rb", 1, "one"),
			Sus::Output::Backtrace::Location.new(__FILE__, 2, "two"),
			Sus::Output::Backtrace::Location.new(__FILE__, 3, "three"),
			Sus::Output::Backtrace::Location.new("/tmp/four.rb", 4, "four"),
		]
		
		backtrace = subject.new(stack, backtrace_path_root)
		
		expect(backtrace.filter.map(&:label)).to be == ["one", "two", "three"]
	end
	
	with "a wonky exception" do
		let(:exception) {Exception.new}
		
		it "has a backtrace" do
			# This causes the exception to have a backtrace but not backtrace_locations.
			exception.set_backtrace(caller)
			
			expect(exception.backtrace_locations).to be_nil
			
			stack = subject.extract_stack(exception)
			expect(stack).to be_a(Array)
			expect(stack).to have_attributes(size: be >= 1)
			
			# This is a compatibility wrapper...
			expect(stack.first).to be_a(Sus::Output::Backtrace::Location)
		end
	end
end
