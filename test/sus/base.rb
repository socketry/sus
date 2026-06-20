# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

describe Sus::Base do
	let(:assertions) {Sus::Assertions.new(output: Sus::Output.buffered)}
	
	it "can inspect itself" do
		base = Sus.base("example")
		instance = base.new(assertions)
		
		expect(instance.inspect).to be == "#<Sus::Base for \"example\">"
	end
	
	it "runs after hooks when the block raises" do
		instance = subject.new(assertions)
		
		begin
			instance.around do
				raise "boom"
			end
		rescue RuntimeError => error
			expect(error.message).to be == "boom"
		end
	end
	
	it "can inform through assertions" do
		instance = subject.new(assertions)
		instance.inform("hello")
		
		expect(assertions.output.string).to be(:include?, "hello")
	end
end
