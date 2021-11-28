describe Sus::Registry.new do
	it "can load a test file" do
		subject.load(__FILE__)
		
		expect(subject.base.children).to be(:any?)
	end
end
