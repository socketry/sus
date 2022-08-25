# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

describe Sus::With do
	with 'nested contexts' do
		let(:context) do
			Sus::With.build(self.class, 'a test variable', {}) {}
		end
		
		it 'can print context name' do
			buffer = Sus::Output.buffered
			context.print(buffer)
			expect(buffer.string).to be == "describe Sus::With with nested contexts it can print context name test/sus/with.rb:7 with a test variable"
		end
	end
end
