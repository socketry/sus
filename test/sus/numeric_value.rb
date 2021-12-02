NumericValue = Sus::Shared("numeric value") do
	it "is an numeric value" do
		expect(subject).to be(:kind_of?, Numeric)
	end
end
