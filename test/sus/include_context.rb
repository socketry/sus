# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

AContextWithArguments = Sus::Shared("a context with arguments") do |key, value: 42|
	let(:a_thing) {{key => value}}
end

AContextWithHooks = Sus::Shared("a context with hooks") do
	before do
		events << :shared_before
	end
	
	after do
		events << :shared_after
	end
	
	around do |&block|
		events << :shared_around_before
		super(&block)
	end
end

describe Sus::Context do
	with '.include_context' do
		with "a shared context with an option" do
			include_context AContextWithArguments, :key, value: 42
			
			it "can include a shared context with arguments" do
				expect(a_thing).to be == {:key => 42}
			end
		end
		
		with "a shared context with arguments" do
			let(:events) {Array.new}
			
			include AContextWithHooks
			
			before do
				events << :example_before
			end
			
			it "can include a shared context" do
				expect(events).to be == [:example_before, :shared_around_before, :shared_before]
			end
		end
	end
end
