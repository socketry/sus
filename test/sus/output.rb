require 'sus/output'

describe Sus::Output do
	it "should incremently generate output"	do
		10.times do
			expect(true).to be == false
			sleep 1
		end
	end
end
