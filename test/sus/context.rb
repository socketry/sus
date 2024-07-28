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
	
	it "has a full name" do
		expect(instance.full_name).to be == "describe test"
	end
	
	with "before hooks" do
		let(:events) {Array.new}
		
		before do
			events << :before1
		end
		
		before do
			events << :before2
		end
		
		it "invokes before hooks" do
			expect(events).to be == [:before1, :before2]
		end
	end
	
	with "after hooks" do
		let(:events) {Array.new}
		
		after do
			events << :after1
			expect(events).to be == [:example, :after2, :after1]
		end
		
		after do
			events << :after2
		end
		
		it "invokes after hooks" do
			events << :example
		end
	end
end

describe Sus::With do
	let(:describe) {Sus::Describe.build(Sus.base, "test")}
	let(:instance) {subject.build(describe, "hash", {x: 10})}
	it_behaves_like Context
	
	it "has a full name" do
		expect(instance.full_name).to be == "describe test with hash"
	end
end
