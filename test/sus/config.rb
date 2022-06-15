describe Sus::Config do
	let(:config) {subject.load}
	
	it "can load config from file" do
		expect(config).not.to be(:nil?)
	end
end
