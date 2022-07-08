class MyObject
	def my_method
		"Hello"
	end
end

describe Sus::Mock do
	it "can mock an object" do
		intercepted = false
		
		mock(MyObject).intercept(:new) do
			intercepted = true
			super()
		end
		
		MyObject.new
		
		expect(intercepted).to be == true
	end
end
