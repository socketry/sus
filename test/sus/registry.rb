
describe Sus::Registry do
	let(:subject) {Sus::Registry.new}
	
	it "can load a test file" do
		subject.load(__FILE__)
		
		assert(subject.base.children.any?)
	end
end
