describe Sus::Assertions do
	let(:inverted) {false}
	let(:subject) {Sus::Assertions.new(output: Sus::Terminal.buffered, inverted: inverted)}
	
	it "defaults to passing" do
		expect(subject).to be(:passed?)
		expect(subject).not.to be(:failed?)
	end
	
	it "can assert something true" do
		subject.assert(true)
		
		expect(subject.passed).to be == 1
		expect(subject.failed).to be == 0
		expect(subject.count).to be == 1
		
		expect(subject).to be(:passed?)
		expect(subject).not.to be(:failed?)
	end
	
	it "can assert something false" do
		subject.assert(false)
		
		expect(subject.passed).to be == 0
		expect(subject.failed).to be == 1
		expect(subject.count).to be == 1
		
		expect(subject).not.to be(:passed?)
		expect(subject).to be(:failed?)
	end
	
	with "inverted assertions", inverted: true do
		it "can assert something true" do
			subject.assert(true)
			
			expect(subject).not.to be(:passed?)
			expect(subject).to be(:failed?)
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
			expect(subject.passed).to be == 2
			expect(subject.count).to be == 4
		end
	end
end
