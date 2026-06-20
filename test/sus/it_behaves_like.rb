# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2026, by Samuel Williams.

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

describe Sus::ItBehavesLike do
	it "can print itself" do
		shared = Sus::Shared("shared"){}
		context = subject.build(Sus.base, shared)
		output = Sus::Output.buffered
		
		context.print(output)
		
		expect(output.string).to be(:include?, "it behaves like")
	end
end

describe Sus::Shared do
	it "can be prepended" do
		shared = Sus::Shared("prepended") do
			@prepended_value = :value
		end
		
		context = Sus.base
		context.singleton_class.prepend(shared)
		
		expect(context.singleton_class.instance_variable_get(:@prepended_value)).to be == :value
	end
end
