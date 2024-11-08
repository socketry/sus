# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

AContextWithArguments = Sus::Shared("a context with arguments") do |key, value: 42|
	let(:a_thing) {{key => value}}
end

AContextWithHooks = Sus::Shared("a context with hooks") do
	before do
		events << :context_before
	end
	
	after do
		events << :context_after
	end
	
	around do |&block|
		events << :context_around_before
		
		super() do
			events << :context_around_super_before
			block.call
			events << :context_around_super_after
		end
		
		events << :context_around_after
	end
end

describe Sus::Context do
	with ".include_context" do
		with "a shared context with an option" do
			include_context AContextWithArguments, :key, value: 42
			
			it "can include a shared context with arguments" do
				expect(a_thing).to be == {:key => 42}
			end
		end
		
		with "a shared context with hooks" do
			let(:events) {Array.new}
			
			include AContextWithHooks
			
			before do
				events << :example_before
			end
			
			after do
				events << :example_after
			end
			
			around do |&block|
				events << :example_around_before
				
				super() do
					events << :example_around_super_before
					block.call
					events << :example_around_super_after
				end
				
				events << :example_around_after
				
				# This is the full sequence of events:
				expect(events).to be == [
					:example_around_before,
					:context_around_before,
					:context_before,
					:example_before,
					:context_around_super_before,
					:example_around_super_before,
					:example,
					:example_around_super_after,
					:context_around_super_after,
					:example_after,
					:context_after,
					:context_around_after,
					:example_around_after,
				]
			end
			
			it "can include a shared context" do
				events << :example
				
				expect(events).to be == [
					:example_around_before,
					:context_around_before,
					:context_before,
					:example_before,
					:context_around_super_before,
					:example_around_super_before,
					:example,
				]
			end
		end
	end
end
