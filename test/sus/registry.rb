# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

describe Sus::Registry.new do
	it "can load a test file" do
		subject.load(__FILE__)

		expect(subject.base.children).to be(:any?)
	end

	it "can load a folder" do
		existing_count = subject.base.children.length
		subject.load("#{__dir__}/fixtures/registry_folder_test")

		found_files = subject.base.children.keys.map(&:key)

		expect(found_files.include?("#{__dir__}/fixtures/registry_folder_test/folder_test.rb")).to be == true
		expect(found_files.include?("#{__dir__}/fixtures/registry_folder_test/nested_folder/nested_folder_test.rb")).to be == true
		expect(found_files.length).to be(:==, existing_count + 2)
	end
end
