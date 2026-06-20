# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

class Nested
	def initialize(name)
		@name = name
	end
	
	def print(output)
		output.write("nested ", :variable, @name)
	end
end

describe Sus::Assertions do
	let(:inverted) {false}
	let(:identity) {Sus::Identity.new("fake.rb", "fake", 1)}
	let(:assertions) {Sus::Assertions.new(identity: identity, output: Sus::Output.buffered, inverted: inverted)}
	
	with "empty assertions" do
		it "defaults to passing" do
			expect(assertions).to be(:passed?)
			expect(assertions).not.to be(:failed?)
		end
		
		it "can assert something true" do
			assertions.assert(true)
			
			expect(assertions.passed.size).to be == 1
			expect(assertions.failed.size).to be == 0
			expect(assertions.count).to be == 1
			
			expect(assertions).to be(:passed?)
			expect(assertions).not.to be(:failed?)
		end
		
		it "can assert something false" do
			assertions.assert(false)
			
			expect(assertions.passed.size).to be == 0
			expect(assertions.failed.size).to be == 1
			expect(assertions.count).to be == 1
			
			expect(assertions).not.to be(:passed?)
			expect(assertions).to be(:failed?)
		end
		
		it "can add informational output" do
			assertions.inform("Hello world")
			
			expect(assertions.output).to have_attributes(
				string: be =~ /Hello world/
			)
		end
		
		it "can add informational output from a block" do
			assertions.inform do
				"Hello block"
			end
			
			expect(assertions.output).to have_attributes(
				string: be =~ /Hello block/
			)
		end
		
		it "can add informational output from a failing block" do
			assertions.inform do
				raise "Boom"
			end
			
			expect(assertions.output).to have_attributes(
				string: be =~ /Boom/
			)
		end
		
		it "can report its message and emptiness" do
			expect(assertions.empty?).to be == true
			expect(assertions.message).to be(:include?, :text)
		end
	end
	
	# Inverted assertions mean that we are passing if at least one assertion fails!
	with "inverted assertions", inverted: true do
		it "can assert something true" do
			assertions.assert(true)
			
			expect(assertions).not.to be(:passed?)
			expect(assertions).to be(:failed?)
		end
		
		it "can assert something false" do
			assertions.assert(false)
			
			expect(assertions).to be(:passed?)
			expect(assertions).not.to be(:failed?)
		end
		
		it "can assert something true and false" do
			assertions.assert(true)
			assertions.assert(false)
			
			expect(assertions).to be(:passed?)
			expect(assertions).not.to be(:failed?)
		end
	end
	
	with "aggregations" do
		let(:child) {Sus::Assertions.new}
		
		it "can add assertions" do
			child.assert(true)
			child.assert(true)
			
			assertions.add(child)
			assertions.add(child)
			
			expect(assertions).to be(:passed?)
			expect(assertions.passed.size).to be == 4
			expect(assertions.count).to be == 4
		end
	end
	
	with "printing" do
		let(:output) {Sus::Output.buffered}
		
		it "prints verbose target output" do
			assertions = Sus::Assertions.new(target: Nested.new("target"), output: Sus::Output.buffered, verbose: true)
			assertions.assert(true)
			assertions.print(output)
			
			expect(output.string).to be(:include?, "nested target")
		end
		
		it "prints deferred, skipped and errored counts" do
			assertions.assert(true)
			assertions.defer{}
			assertions.skip("skip")
			assertions.error!(RuntimeError.new("boom"))
			assertions.print(output)
			
			expect(output.string).to be(:include?, "deferred")
			expect(output.string).to be(:include?, "skipped")
			expect(output.string).to be(:include?, "errored")
		end
	end
	
	with "failures" do
		it "can enumerate failed assertions" do
			assertions.assert(false)
			
			failures = assertions.each_failure.to_a
			
			expect(failures).to have_attributes(size: be == 1)
			expect(failures.first.message).to be(:include?, :text)
		end
		
		it "can enumerate errored assertions" do
			assertions.error!(RuntimeError.new("boom"))
			
			failures = assertions.each_failure.to_a
			
			expect(failures).to have_attributes(size: be == 1)
			expect(failures.first.message[:text]).to be(:include?, "boom")
		end
		
		it "can treat failed assertions as distinct" do
			assertions = Sus::Assertions.new(output: Sus::Output.buffered, distinct: true)
			assertions.assert(false)
			
			failures = assertions.each_failure.to_a
			
			expect(failures).to be == [assertions]
		end
	end
	
	it "can write directly to its output" do
		assertions.puts("hello")
		
		expect(assertions.output.string).to be(:include?, "hello")
	end
	
	with "deferred assertions" do
		it "can defer an assertion" do
			assertions.defer do
				assertions.assert(true)
			end
			
			expect(assertions.count).to be == 0
			assertions.resolve!
			expect(assertions.count).to be == 1
			
			expect(assertions).to be(:passed?)
			expect(assertions).not.to be(:failed?)
		end
		
		it "can defer a nested assertion" do
			assertions.nested(Nested.new("outer"), isolated: true) do |assertions|
				assertions.nested(Nested.new("inner")) do |assertions|
					assertions.defer do
						assertions.assert(true)
					end
					
					expect(assertions.deferred?).to be == true
					expect(assertions.count).to be == 0
				end
				
				expect(assertions.deferred?).to be == true
				expect(assertions.count).to be == 0
			end
			
			expect(assertions.deferred?).to be == false
			expect(assertions.count).to be == 1
			
			expect(assertions).to be(:passed?)
			expect(assertions).not.to be(:failed?)
		end
	end
	
	with "nested assertions" do
		it "can nest assertions and preserve identity" do
			assertions.nested(Nested.new("outer")) do |assertions|
				expect(assertions.identity).to be_equal(identity)
			end
		end
	end
end
