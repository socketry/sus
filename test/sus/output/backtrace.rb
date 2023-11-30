# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'sus/output/status'

describe Sus::Output::Backtrace do
	let(:identity) {Sus::Identity.current}
	let(:backtrace) {subject.new(caller_locations)}
	
	it "has several frames" do
		expect(backtrace.stack).to have_attributes(size: be >= 1)
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
	
	with "a wonky exception" do
		let(:exception) {Exception.new}
		
		it "has a backtrace" do
			# This causes the exception to have a backtrace but not backtrace_locations.
			exception.set_backtrace(caller)
			
			stack = subject.extract_stack(exception)
			expect(stack).to be_a(Array)
			expect(stack).to have_attributes(size: be >= 1)
			
			# This is a compatibility wrapper...
			expect(stack.first).to be_a(Sus::Output::Backtrace::Location)
		end
	end
end
