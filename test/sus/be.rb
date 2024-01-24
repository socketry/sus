# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

describe Sus::Be do
	with "true" do
		it "can expect equality" do
			expect(true).to be == true
			
		end
		
		it "can expect inequality" do
			expect(true).to be != false
		end
		
		it "can be truthy" do
			expect(true).to be_truthy
		end
		
		it "can't be falsey" do
			expect(true).not.to be_falsey
		end
	end
	
	with "false" do
		it "can expect equality" do
			expect(false).to be == false
		end
		
		it "can be falsey" do
			expect(false).to be_falsey
		end
		
		it "can't be truthy" do
			expect(false).not.to be_truthy
		end
	end
	
	with "nil" do
		it "can expect equality" do
			expect(nil).to be == nil
		end
		
		it "can be falsey" do
			expect(nil).to be_falsey
		end
		
		it "can't be truthy" do
			expect(nil).not.to be_truthy
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
		it "can compare equality" do
			expect([1, 2, 3]).to be == [1, 2, 3]
		end
	end
	
	describe Sus::Be::NIL do
		let(:buffer) {StringIO.new}
		let(:output) {Sus::Output::Text.new(buffer)}
		
		it "can print" do
			subject.print(output)
			expect(buffer.string).to be == "be nil?"
		end
	end
end
