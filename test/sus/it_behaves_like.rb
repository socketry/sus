# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

ContextModule = Sus::Shared("context module") do
	it "extends context" do
		expect(subject.singleton_class.ancestors).to be(:include?, Sus::Context)
	end
end

[Sus::Describe, Sus::File, Sus::With].each do |klass|
	describe klass, unique: klass do
		it_behaves_like ContextModule
	end
end

TestThing = Sus::Shared("test thing") do
	it "should define a truthy thing" do
		expect(thing).to be == true
	end
end

with "a falsey thing" do
	let(:thing) {false}
	
	it "should define a falsey thing" do
		expect(thing).to be == false
	end
	
	# Test that the nested thing overrides the one above:
	it_behaves_like TestThing do
		let(:thing) {true}
	end
end
