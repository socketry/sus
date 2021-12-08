describe Sus::HaveDuration do
	it "can have a duration for a short sleep" do
		expect{sleep 0.1}.to have_duration >= 0.1
	end
	
	it "can have a duration within a given range" do
		expect{sleep 0.1}.to have_duration(0..0.2)
	end
end
