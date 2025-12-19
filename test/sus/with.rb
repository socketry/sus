# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

describe Sus::With do
	with "nested contexts" do
		let(:context) do
			Sus::With.build(self.class, "a test variable", {}){}
		end
		
		it "has a description" do
			expect(context.description).to be == "a test variable"
		end
		
		it "can print context name" do
			buffer = Sus::Output.buffered
			context.print(buffer)
			expect(buffer.string).to be =~ %r{describe Sus::With with nested contexts it can print context name test/sus/with.rb:\d+ with a test variable}
		end
	end
	
	with "unique:" do
		it "can be unique" do
			base = Sus.base
			with = base.with("test", unique: "test"){}
			expect(with.identity).to have_attributes(unique: be == "test")
		end
	end
end
