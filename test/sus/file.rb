# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

FILE = self

describe Sus::File do
	it "has a class name" do
		skip_unless_method_defined(:set_temporary_name, Module)
		
		expect(FILE.name).to be == "Sus::File[#{__FILE__}]"
	end
end
