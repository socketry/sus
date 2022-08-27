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
end
