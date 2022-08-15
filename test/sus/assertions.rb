class Nested
	def initialize(name)
		@name = name
	end
	
	def print(output)
		output.write("nested ", :variable, @name)
	end
end

describe Sus::Assertions do
	let(:inverted) {false}
	let(:subject) {Sus::Assertions.new(output: Sus::Output.buffered, inverted: inverted)}
	
	it "defaults to passing" do
		expect(subject).to be(:passed?)
		expect(subject).not.to be(:failed?)
	end
	
	it "can assert something true" do
		subject.assert(true)
		
		expect(subject.passed.size).to be == 1
		expect(subject.failed.size).to be == 0
		expect(subject.count).to be == 1
		
		expect(subject).to be(:passed?)
		expect(subject).not.to be(:failed?)
	end
	
	it "can assert something false" do
		subject.assert(false)
		
		expect(subject.passed.size).to be == 0
		expect(subject.failed.size).to be == 1
		expect(subject.count).to be == 1
		
		expect(subject).not.to be(:passed?)
		expect(subject).to be(:failed?)
	end
	
	# Inverted assertions mean that we are passing if at least one assertion fails!
	with "inverted assertions", inverted: true do
		it "can assert something true" do
			subject.assert(true)
			
			expect(subject).not.to be(:passed?)
			expect(subject).to be(:failed?)
		end
		
		it "can assert something false" do
			subject.assert(false)
			
			expect(subject).to be(:passed?)
			expect(subject).not.to be(:failed?)
		end
		
		it "can assert something true and false" do
			subject.assert(true)
			subject.assert(false)
			
			expect(subject).to be(:passed?)
			expect(subject).not.to be(:failed?)
		end
	end
	
	with "aggregations" do
		let(:child) {Sus::Assertions.new}
		
		it "can add assertions" do
			child.assert(true)
			child.assert(true)
			
			subject.add(child)
			subject.add(child)
			
			expect(subject).to be(:passed?)
			expect(subject.passed.size).to be == 4
			expect(subject.count).to be == 4
		end
	end
	
	with 'deferred assertions' do
		it "can defer an assertion" do
			subject.defer do
				subject.assert(true)
			end
			
			expect(subject.count).to be == 0
			subject.resolve!
			expect(subject.count).to be == 1
			
			expect(subject).to be(:passed?)
			expect(subject).not.to be(:failed?)
		end
		
		it "can defer a nested assertion" do
			subject.nested(Nested.new('outer'), isolated: true) do |assertions|
				assertions.nested(Nested.new('inner')) do |assertions|
					assertions.defer do
						assertions.assert(true)
					end
					
					expect(assertions.deferred?).to be == true
					expect(assertions.count).to be == 0
				end
				
				expect(assertions.deferred?).to be == true
				expect(assertions.count).to be == 0
			end
			
			expect(subject.deferred?).to be == false
			expect(subject.count).to be == 1
			
			expect(subject).to be(:passed?)
			expect(subject).not.to be(:failed?)
		end
	end
end
