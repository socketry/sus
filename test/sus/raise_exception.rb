# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

class AgeError < StandardError
	def initialize(age)
		@age = age
		super "Too old: #{age}"
	end
	
	attr :age
end

describe Sus::RaiseException do
	it "can raise an exception with a matching message" do
		expect do
			raise "Boom"
		end.to raise_exception(RuntimeError, message: be =~ /Boom/)
	end
	
	it "can not raise an exception" do
		expect do
			# Nothing.
		end.not.to raise_exception
	end
	
	with "custom exception" do
		it "can raise an exception with matching attributes" do
			expect do
				raise AgeError.new(20)
			end.to raise_exception(AgeError, message: be =~ /Too old/).and(have_attributes(age: be >= 20))
		end
	end
	
	with "failed expectation" do
		it "includes the exception message when it fails" do
			assertions = Sus::Assertions.new
			Sus::Expect.new(assertions, ->{raise "Boom"}).to raise_exception(RuntimeError, message: be =~ /Bam/)
			
			expect(assertions.output.string).to be =~ /expect "Boom"/
		end
	end
end
