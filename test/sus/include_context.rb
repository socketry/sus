# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

AThing = Sus::Shared("a thing") do |key, value: 42|
	let(:a_thing) {{key => value}}
	
	include do
		def before
			super
			
			events << :shared_before
		end
	end
end

describe Sus::Context do
	with '.include_context' do
		with "a shared context with an option" do
			let(:events) {Array.new}
			include_context AThing, :key, value: 42
			
			def before
				super
				
				events << :example_before
			end
			
			it "can include a shared context" do
				expect(a_thing).to be == {:key => 42}
				expect(events).to be == [:shared_before, :example_before]
			end
		end
	end
end
