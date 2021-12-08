describe Sus::BeWithin do
	it "can expect number to be within a tolerance" do
		expect(0).to be_within(10)
		expect(5).to be_within(10)
	end
	
	it "can expect number to be outside of a tolerance" do
		expect(10).not.to be_within(10)
		expect(15).not.to be_within(10)
	end
	
	with Range do
		it "can expect number to be within a range" do
			expect(5).to be_within(2..7)
			expect(2).to be_within(2..7)
			expect(7).to be_within(2..7)
		end
		
		it "can expect number to be outside of a range" do
			expect(1).not.to be_within(2..7)
			expect(8).not.to be_within(2..7)
			expect(7).not.to be_within(2...7)
		end
	end
	
	with '#of' do
		it "can expect number to be within an absolute tolerance" do
			expect(8).to be_within(2).of(10)
			expect(10).to be_within(2).of(10)
			expect(12).to be_within(2).of(10)
		end
		
		it "can expect number to be outside of an absolute tolerance" do
			expect(7).not.to be_within(2).of(10)
			expect(13).not.to be_within(2).of(10)
		end
	end
end
