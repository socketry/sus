# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

Context = Sus::Shared("context") do
	it "can define a nested example" do
		instance.it("has an example") {}
		
		expect(instance.children).not.to be(:empty?)
	end
	
	it "does not include unnecessary variables" do
		expect(binding.local_variables).to be(:include?, :__klass__)
		expect(binding.local_variables).to be(:include?, :__path__)
		
		binding.local_variables.each do |variable_name|
			expect(variable_name.to_s).to be(:start_with?, '_')
		end
	end
end

describe Sus::Describe do
	let(:instance) {subject.build(Sus.base, "test")}
	it_behaves_like Context
end

describe Sus::With do
	let(:instance) {subject.build(Sus.base, "test", {x: 10})}
	it_behaves_like Context
end
