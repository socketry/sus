# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "sus/fixtures/temporary_directory_context"

describe Sus::Fixtures::TemporaryDirectoryContext do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	it "creates a temporary directory" do
		expect(root).not.to be(:nil?)
		expect(root).to be_a(String)
		expect(File.directory?(root)).to be == true
	end
	
	it "provides access to the root path" do
		expect(root).to be_a(String)
		expect(root).not.to be(:empty?)
	end
	
	it "allows creating files in the temporary directory" do
		test_file = File.join(root, "test.txt")
		File.write(test_file, "test content")
		
		expect(File.exist?(test_file)).to be == true
		expect(File.read(test_file)).to be == "test content"
	end
end
