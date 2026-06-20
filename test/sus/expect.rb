# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

describe Sus::Expect do
	let(:assertions) {Sus::Assertions.new(output: Sus::Output.buffered)}
	
	with "a hash table" do
		let(:target) {Hash.new}
		
		it "can expect equality" do
			expect(target).to be == {}
		end
		
		it "can expect to include" do
			target[:key] = "value"
			expect(target).to be(:include?, :key)
		end
	end
	
	it "can print inverted expectations" do
		expectation = Sus::Expect.new(assertions, "value").not
		buffer = Sus::Output::Buffered.new
		
		expectation.print(buffer)
		
		expect(buffer.string).to be == "expect \"value\" not to"
	end
	
	it "can chain expectations with and" do
		expectation = Sus::Expect.new(assertions, "value")
		
		expectation.and(be == "value")
		
		expect(assertions.count).to be == 1
	end
	
	with "exceptions" do
		let(:identity) {Sus::Identity.new(__FILE__)}
		let(:expectation) {Sus::Expect.new(assertions, Object.new)}
		
		it "is expected to propagate errors" do
			expectation.not.to be(:no_such_method?)
			expect(assertions).to be(:errored?)
		end
	end
end
