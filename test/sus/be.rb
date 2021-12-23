describe Sus::Be do
	with "true" do
		it "can expect equality" do
			expect(true).to be == true
		end
	end
	
	with "false" do
		it "can expect equality" do
			expect(false).to be == false
		end
	end
	
	with "nil" do
		it "can expect equality" do
			expect(nil).to be == nil
		end
	end
end
