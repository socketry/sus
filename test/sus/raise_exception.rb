describe Sus::RaiseException do
	it "can raise an exception with a matching message" do
		expect do
			raise "Boom"
		end.to raise_exception(RuntimeError, message: /Boom/)
	end
	
	it "can not raise an exception" do
		expect do
		end.not.to raise_exception
	end
end
