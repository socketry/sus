# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

describe Sus::Expect do
	with 'a hash table' do
		let(:target) {Hash.new}
		
		it "can expect equality" do
			expect(target).to be == {}
		end
	end
	
	with "exceptions" do
		let(:assertions) {Sus::Assertions.new}
		let(:expectation) {Sus::Expect.new(assertions, Object.new)}
		
		it "is expected to propagate errors" do
			expectation.not.to be(:no_such_method?)
			expect(assertions).to be(:errored?)
		end
	end
end
