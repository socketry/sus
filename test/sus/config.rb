# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

require 'fixtures'

describe Sus::Config do
	include Fixtures
	
	let(:root) {fixtures_path('sus/config/empty')}
	let(:config) {subject.load(root: root)}
	
	it "can load config from file" do
		expect(config).not.to be(:nil?)
	end
end
