# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

require "sus/fixtures/temporary_directory_context"

describe Sus::Fixtures::TemporaryDirectoryContext do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	let(:assertions) {Sus::Assertions.new(output: Sus::Output.buffered)}
	
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
	
	it "removes the temporary directory after use" do
		context = Sus.base("temporary directory")
		context.include(Sus::Fixtures::TemporaryDirectoryContext)
		instance = context.new(assertions)
		
		root = nil
		
		instance.around do
			root = instance.root
			
			expect(File.directory?(root)).to be == true
		end
		
		expect(File.exist?(root)).to be == false
	end
	
	it "tolerates already removed temporary directories during cleanup" do
		context = Sus.base("temporary directory")
		context.include(Sus::Fixtures::TemporaryDirectoryContext)
		instance = context.new(assertions)
		
		root = nil
		
		expect do
			instance.around do
				root = instance.root
				FileUtils.remove_entry(root)
			end
		end.not.to raise_exception
		
		expect(File.exist?(root)).to be == false
	end
end
