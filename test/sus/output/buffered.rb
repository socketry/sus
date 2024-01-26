# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'sus/output/buffered'

class StatefulThing
	def initialize
		@state = :initial
	end
	
	def inspect
		"#<#{self.class.name} #{@state}>"
	end
	
	def close
		@state = :closed
	end
	
	def closed?
		@state == :closed
	end
end

describe Sus::Output::Buffered do
	let(:assertions) {Sus::Assertions.new(output: Sus::Output.buffered)}
	
	with StatefulThing do
		it "correctly displays output" do
			stateful_thing = StatefulThing.new
			
			context = Sus::It.build(self.class, "is closed") do
				expect(stateful_thing).to be(:closed?)
			end
			
			context.call(assertions)
			
			# Change the state of the object that was expected:
			stateful_thing.close
			
			# The output should reflect the state of the object at the time the expectation failed:
			expect(assertions.output.string).to be =~ /StatefulThing initial/
		end
	end
end
