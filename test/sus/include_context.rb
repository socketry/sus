# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

AThing = Sus::Shared("a thing") do |key, value: 42|
	let(:a_thing) {{key => value}}
end

describe Sus::Context do
	with '.include_context' do
		with "a shared context with an option" do
			include_context AThing, :key, value: 42
			
			it "can include a shared context" do
				expect(a_thing).to be == {:key => 42}
			end
		end
	end
end
