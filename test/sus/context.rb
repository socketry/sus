Context = Sus::Shared("context") do
	it "can define a nested example" do
		instance.it("has an example") {}
		
		expect(instance.children).not.to be(:empty?)
	end
end

describe Sus::Describe do
	let(:instance) {subject.build(Sus.base, "test")}
	it_behaves_like Context
end

describe Sus::With do
	let(:instance) {subject.build(Sus.base, "test", {x: 10})}
	it_behaves_like Context
end
