# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

FILE = self

describe Sus::File do
	it "has a class name" do
		skip_unless_method_defined(:set_temporary_name, Module)
		
		expect(FILE.name).to be == "Sus::File[#{__FILE__}]"
	end
	
	it "can load a file using []" do
		file = subject[__FILE__]
		
		expect(file.description).to be == __FILE__
	end
	
	it "captures file load errors" do
		path = File.expand_path("../../fixtures/sus/file/error.rb", __dir__)
		file = subject.build(Sus.base, path)
		child = file.children.values.first
		
		expect(child).to be(:leaf?)
		expect(child.children).to be(:empty?)
		expect(child.description).to be == path
		
		output = Sus::Output.buffered
		child.print(output)
		expect(output.string).to be(:include?, "file")
		
		assertions = Sus::Assertions.new(output: Sus::Output.buffered)
		child.call(assertions)
		expect(assertions.errored).not.to be(:empty?)
	end
	
	it "captures syntax errors with line numbers" do
		path = File.expand_path("../../fixtures/sus/file/syntax_error.sus", __dir__)
		file = subject.build(Sus.base, path)
		child = file.children.values.first
		
		expect(child.identity.line).to be == 3
	end
	
	it "can extract line numbers from syntax errors" do
		error = SyntaxError.new("example.rb:123: syntax error")
		
		expect(error.lineno).to be == 123
	end
end
