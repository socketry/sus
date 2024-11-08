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
