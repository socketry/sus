require_relative 'numeric_value'

describe Sus::Context do
	with "an integer", subject: 10 do
		it_behaves_like NumericValue
	end
	
	with "a float", subject: 10.1 do
		it_behaves_like NumericValue
	end
end
