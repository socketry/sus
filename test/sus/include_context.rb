# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

AThing = Sus::Shared("a thing") do |key, value: 42|
	let(:a_thing) {{key => value}}
	
	before do
		$stderr.puts "before: #{self}"
		events << :shared_before
	end
	
	after do
		$stderr.puts "after: #{self}"
		events << :shared_after
	end
	
	around do |block|
		$stderr.puts "around: #{self}"
		block.call
	end
end

describe Sus::Context do
	with '.include_context' do
		with "a shared context with an option" do
			let(:events) {Array.new}
			include_context AThing, :key, value: 42
			
			before do
				events << :example_before
			end
			
			it "can include a shared context" do
				expect(a_thing).to be == {:key => 42}
				expect(events).to be == [:shared_before, :example_before]
			end
		end
	end
end
