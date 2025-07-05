# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

class RealImplementation
	def initialize(value = nil)
		@value = value
	end
	
	attr :value
	
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

describe Sus::Mock do
	let(:interface) {Interface.new}
	
	it "can expect a method to be called" do
		expect(interface).to receive(:implementation)
		interface.implementation
	end
	
	it "can expect a method to be called with arguments" do
		expect(interface).to receive(:implementation).with(10)
		interface.implementation(10)
	end
	
	it "can expect a method to be called and return a value" do
		expect(interface).to receive(:implementation).and_return(10)
		expect(interface.implementation).to be == 10
	end
	
	it "can expect a method to be called and call a block" do
		expect(interface).to receive(:implementation){|*arguments|
			"Called with arguments: #{arguments.first}"
		}
		
		expect(interface.implementation(10)).to be == "Called with arguments: 10"
	end
	
	it "can expect a method to be called and raise an exception" do
		expect(interface).to receive(:implementation).and_raise(RuntimeError, "An error occurred")
		expect{interface.implementation}.to raise_exception(RuntimeError, message: be =~ /An error occurred/)
	end
	
	it "can replace a method on an object" do
		mock(interface) do |mock|
			mock.replace(:implementation) do
				FakeImplementation.new
			end
		end

		expect(interface).to be(:kind_of?, Interface)
		expect(interface.implementation).to be(:kind_of?, FakeImplementation)
	end

	it "can execute code before a method is executed" do
		count = 0

		mock(interface) do |mock|
			mock.before(:implementation) do
				count += 1
			end
		end

		expect(interface.implementation).to be(:kind_of?, RealImplementation)
		expect(count).to be == 1
	end

	it "can execute code after a method is executed" do
		count = 0

		mock(interface) do |mock|
			mock.after(:implementation) do |result|
				count += 1
			end
		end

		expect(interface.implementation).to be(:kind_of?, RealImplementation)
		expect(count).to be == 1
	end

	with "#replace" do
		def before
			mock(RealImplementation) do |mock|
				mock.replace(:new) do
					FakeImplementation.new
				end
			end
		end

		it "can mock class methods" do
			interface = Interface.new
			expect(interface.implementation).to be(:kind_of?, FakeImplementation)
		end

		it "doesn't affect other threads" do
			Thread.new do
				interface = Interface.new
				expect(interface.implementation).to be(:kind_of?, RealImplementation)
			end.join
		end
	end
	
	with "#wrap" do
		def before
			mock(RealImplementation) do |mock|
				mock.wrap(:new) do |original, value|
					original.call(value * 2)
				end
			end
		end
		
		it "can wrap a method" do
			interface = RealImplementation.new(10)
			expect(interface.value).to be == 20
		end
	end
end
