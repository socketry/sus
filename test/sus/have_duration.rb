# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

describe Sus::HaveDuration do
	def render(predicate)
		buffer = Sus::Output::Buffered.new
		predicate.print(buffer)
		return buffer.string
	end
	
	it "can print" do
		expect(render(have_duration(be >= 0.01))).to be == "have duration be >= 0.01"
	end
	
	it "can have a duration for a short sleep" do
		expect{sleep 0.01}.to have_duration(be >= 0.01)
	end
	
	it "can have a duration within a given range" do
		expect{sleep 0.01}.to have_duration(be_within(0.01..0.1))
	end
end
