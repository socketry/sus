
ContextModule = Sus::Shared("context module") do
	it "extends context" do
		expect(subject.singleton_class.ancestors).to be(:include?, Sus::Context)
	end
end

[Sus::Describe, Sus::File, Sus::With].each do |klass|
	describe klass, unique: klass do
		it_behaves_like ContextModule
	end
end
