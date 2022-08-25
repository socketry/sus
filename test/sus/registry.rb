# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

describe Sus::Registry.new do
	it "can load a test file" do
		subject.load(__FILE__)
		
		expect(subject.base.children).to be(:any?)
	end
end
