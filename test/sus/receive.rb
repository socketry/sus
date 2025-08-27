# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

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
	def implementation(*arguments, **options)
		RealImplementation.new
	end
end

describe Sus::Receive do
	let(:interface) {Interface.new}
	
	it "can validate a method call" do
		expect(interface).to receive(:implementation)
		expect(interface).to be(:kind_of?, Interface)
		expect(interface.implementation).to be(:kind_of?, RealImplementation)
	end
	
	with "#and_return" do
		it "can return a specific value" do
			expect(interface).to receive(:implementation).and_return(FakeImplementation.new)
			
			expect(interface).to be(:kind_of?, Interface)
			expect(interface.implementation).to be(:kind_of?, FakeImplementation)
		end
		
		it "can return multiple values" do
			expect(interface).to receive(:implementation).and_return(true, false)
			
			expect(interface).to be(:kind_of?, Interface)
			expect(interface.implementation).to be == [true, false]
		end
		
		it "can return a block" do
			expect(interface).to receive(:implementation).and_return{|value| "Block Result: #{value}"}
			
			expect(interface).to be(:kind_of?, Interface)
			expect(interface.implementation(10)).to be == "Block Result: 10"
		end
	end
	
	with "#and_raise" do
		it "can raise an error when the method is called" do
			expect(interface).to receive(:implementation).and_raise("Error!")
			expect{interface.implementation}.to raise_exception(RuntimeError, message: be =~ /Error!/)
		end
	end
	
	it "can validate arguments" do
		expect(interface).to receive(:implementation).with(:foo, :bar)
		
		interface.implementation(:foo, :bar)
	end
	
	it "can validate (not) arguments" do
		expect(interface).not.to receive(:implementation).with(:foo, :bar)
		
		interface.implementation(:foo, :bar2)
	end
	
	it "can validate options" do
		expect(interface).to receive(:implementation).with(x: 1, y: 2)
		
		interface.implementation(x: 1, y: 2)
	end
	
	describe Sus::Receive::Times do
		it "expects at least one call by default" do
			expect(interface).to receive(:implementation)
			
			interface.implementation
		end
		
		it "allows multiple calls by default" do
			expect(interface).to receive(:implementation)
			
			interface.implementation
			interface.implementation
		end
	end
end
