# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

describe Sus::Be do
	with "true" do
		it "can expect equality" do
			expect(true).to be == true
		end
		
		it "can expect inequality" do
			expect(true).to be != false
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
	
	with Integer do
		it "can compare greater than numbers" do
			expect(2).to be > 1
		end
		
		it "can compare greater than or equal numbers" do
			expect(1).to be >= 1
			expect(2).to be >= 1
		end
		
		it "can compare lesser than numbers" do
			expect(1).to be < 2
		end
		
		it "can compare lesser than or equal numbers" do
			expect(1).to be <= 2
			expect(2).to be <= 2
		end
	end
	
	with Class do
		it "can compare equivalence" do
			expect(Object).to be === String
		end
	end
	
	with Array do
		it "can compare equality"	do
			expect([1, 2, 3]).to be == [1, 2, 3]
		end
	end
end
