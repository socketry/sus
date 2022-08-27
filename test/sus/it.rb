# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

describe Sus::It do
	let(:assertions) {Sus::Assertions.new(output: Sus::Output.buffered)}
	
	with "hooks" do
		attr_accessor :before_hook_invoked
		attr_accessor :after_hook_invoked
		
		def before
			self.before_hook_invoked = true
		end
		
		def after
			self.after_hook_invoked = true
		end
		
		let(:context) do
			Sus::It.build(self.class, "test") do
				self
			end
		end
		
		it "invokes before hook" do
			instance = context.call(assertions)
			
			assert(instance.before_hook_invoked)
		end
		
		it "invokes after hook" do
			instance = context.call(assertions)
			
			assert(instance.after_hook_invoked)
		end
	end
	
	with "__assertions__" do
		it "counts assertions" do
			assert(true)
			expect(@__assertions__.count).to be == 1
			expect(@__assertions__.passed.size).to be == 2
		end
	end
	
	describe ->{raise "Boom"} do
		it {is_expected.to raise_exception(RuntimeError, message: "Boom")}
	end	
end
