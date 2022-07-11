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
	def implementation
		RealImplementation.new
	end
end

describe Sus::Mock do
	let(:interface) {Interface.new}

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
				result
			end
		end

		expect(interface.implementation).to be(:kind_of?, RealImplementation)
		expect(count).to be == 1
	end
	

	with "mocked class method" do
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
end
