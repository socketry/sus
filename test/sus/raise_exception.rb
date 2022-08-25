# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

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
