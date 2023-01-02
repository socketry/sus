# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

describe Sus::Config do
	let(:config) {subject.load}
	
	it "can load config from file" do
		expect(config).not.to be(:nil?)
	end
end
