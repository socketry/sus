# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

class Interface
	def method_with_options(x: 10, y:)
	end
	
	def method_with_parameters(x, y = nil, **options)
	end
end

describe Sus::RespondTo do
	let(:interface) {Interface.new}
	
	def render(predicate)
		buffer = Sus::Output::Buffered.new
		predicate.print(buffer)
		return buffer.string
	end
	
	it "can print" do
		expect(render(respond_to(:method_with_options))).to be == "respond to method_with_options"
	end
	
	it "can respond to a method" do
		expect(interface).to respond_to(:method_with_options)
	end
	
	it "can respond to a method with one option" do
		expect(interface).to respond_to(:method_with_options).with_options(:x)
	end
	
	it "can respond to a method with several options" do
		expect(interface).to respond_to(:method_with_options).with_options(:x, :y)
	end
	
	it "fails to respond to a method with missing options" do
		expect(interface).not.to respond_to(:method_with_options).with_options(:z)
	end
	
	it "fails to respond to non-existant method" do
		expect(interface).not.to respond_to(:non_existant_method)
	end
	
	describe Sus::RespondTo::WithParameters do
		it "can match required and optional parameters" do
			assertions = Sus::Assertions.new
			subject.new([:x, :y]).call(assertions, interface.method(:method_with_parameters).parameters)
			
			expect(assertions).to be(:passed?)
		end
		
		it "can stop after expected parameters are exhausted" do
			assertions = Sus::Assertions.new
			subject.new([:x]).call(assertions, interface.method(:method_with_parameters).parameters)
			
			expect(assertions).to be(:passed?)
		end
	end
	
	describe Sus::RespondTo::WithOptions do
		it "can print" do
			expect(render(subject.new([:x, :y]))).to be == "with options [:x, :y]"
		end
	end
end
