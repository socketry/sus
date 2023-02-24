# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

describe Sus::Describe do
	with 'nested contexts' do
		let(:context) do
			Sus::Describe.build(self.class, 'a test class') {}
		end
		
		it 'has a description' do
			expect(context.description).to be == 'a test class'
		end
		
		it 'can print context name' do
			buffer = Sus::Output.buffered
			context.print(buffer)
			expect(buffer.string).to be =~ %r{describe a test class}
		end
	end
	
	with "unique:" do
		it "can be unique" do
			base = Sus.base
			with = base.with("test", unique: "test") {}
			expect(with.identity).to have_attributes(unique: be == "test")
		end
	end
end
