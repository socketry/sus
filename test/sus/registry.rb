describe Sus::Registry.new do
	it "can load a test file" do
		subject.load(__FILE__)
		
		assert(subject.base.children.any?)
	end
end
