describe Sus::HaveDuration do
	it "can have a duration for a short sleep" do
		expect{sleep 0.1}.to have_duration(be >= 0.1)
	end
	
	it "can have a duration within a given range" do
		expect{sleep 0.1}.to have_duration(be_within(0.1..0.3))
	end
end
