# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.
# Copyright, 2022, by Brad Schrag.

describe Sus::Registry do
	let(:registry) {subject.new}
	
	it "can load a test file" do
		registry.load(__FILE__)
		
		expect(registry.base.children).to be(:any?)
	end
	
	let(:registry_directory) {File.expand_path(".registry_directory", __dir__)}
	
	it "can load a directory" do
		registry.load(registry_directory)
		
		found_files = registry.base.children.keys.map(&:key)
		
		expect(found_files).to have_value(be =~ /directory_test_file\.rb/)
		expect(found_files).to have_value(be =~ /nested_directory_test_file\.rb/)
	end
end
