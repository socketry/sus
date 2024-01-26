# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

class Interface
	def method_with_options(x: 10, y:)
	end
end

describe Sus::RespondTo do
	let(:interface) {Interface.new}
	
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
end
