# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

class RealImplementation
	def call
		"Real Implementation"
	end
end

class FakeImplementation
	def call
		"Fake Implementation"
	end
end

class Interface
	def implementation(*arguments)
		RealImplementation.new
	end
end

describe Sus::Receive do
	let(:interface) {Interface.new}

	it "can replace a method on an object" do
		expect(interface).to receive(:implementation).and_return(FakeImplementation.new)

		expect(interface).to be(:kind_of?, Interface)
		expect(interface.implementation).to be(:kind_of?, FakeImplementation)
	end

	it "can validate arguments" do
		expect(interface).to receive(:implementation).with(:foo, :bar)

		interface.implementation(:foo, :bar)
	end
	
	it "can validate arguments" do
		expect(interface).not.to receive(:implementation).with(:foo, :bar)

		interface.implementation(:foo, :bar2)
	end
end
