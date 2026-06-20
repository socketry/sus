# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2026, by Samuel Williams.

describe Sus::It do
	let(:assertions) {Sus::Assertions.new(output: Sus::Output.buffered)}
	
	with "hooks" do
		attr_accessor :before_hook_invoked
		attr_accessor :after_hook_invoked
		
		def before
			self.before_hook_invoked = true
		end
		
		def after(error = nil)
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
	
	with "skip" do
		it "can skip tests" do
			context = Sus::It.build(self.class, "test") do
				skip "skipped test"
			end
			
			context.call(assertions)
			
			expect(assertions.output.string).to be =~ /skipped test/
		end
		
		it "can skip when a method is not defined" do
			context = Sus::It.build(self.class, "test") do
				skip_unless_method_defined(:missing_method, String)
			end
			
			context.call(assertions)
			
			expect(assertions.output.string).to be(:include?, "missing_method")
		end
		
		it "can skip when a constant is not defined" do
			context = Sus::It.build(self.class, "test") do
				skip_unless_constant_defined(:MissingConstant)
			end
			
			context.call(assertions)
			
			expect(assertions.output.string).to be(:include?, "MissingConstant")
		end
		
		it "can skip when the platform is not supported" do
			context = Sus::It.build(self.class, "test") do
				skip_if_ruby_platform(/#{Regexp.escape(RUBY_PLATFORM)}/)
			end
			
			context.call(assertions)
			
			expect(assertions.output.string).to be(:include?, "Ruby platform")
		end
	end
	
	with "ruby version requirements" do
		it "compares minimum ruby versions semantically" do
			context = Sus::It.build(self.class, "test") do
				skip_unless_minimum_ruby_version("1.2.3", "1.2.11")
				assert(true)
			end
			
			context.call(assertions)
			
			expect(assertions.skipped).to be(:empty?)
			expect(assertions.count).to be == 1
		end
		
		it "skips when the ruby version is too old" do
			context = Sus::It.build(self.class, "test") do
				skip_unless_minimum_ruby_version("1.2.11", "1.2.3")
			end
			
			context.call(assertions)
			
			expect(assertions.output.string).to be(:include?, "Ruby 1.2.11 is required")
		end
		
		it "compares maximum ruby versions semantically" do
			context = Sus::It.build(self.class, "test") do
				skip_if_maximum_ruby_version("1.2.11", "1.2.3")
				assert(true)
			end
			
			context.call(assertions)
			
			expect(assertions.skipped).to be(:empty?)
			expect(assertions.count).to be == 1
		end
		
		it "skips when the ruby version is too new" do
			context = Sus::It.build(self.class, "test") do
				skip_if_maximum_ruby_version("1.2.3", "1.2.11")
			end
			
			context.call(assertions)
			
			expect(assertions.output.string).to be(:include?, "Ruby 1.2.3 is not supported")
		end
		
		it "compares equal ruby versions" do
			context = Sus::It.build(self.class, "test") do
				skip_unless_minimum_ruby_version("1.2.3", "1.2.3")
				assert(true)
			end
			
			context.call(assertions)
			
			expect(assertions.skipped).to be(:empty?)
			expect(assertions.count).to be == 1
		end
	end
	
	it "has a string representation" do
		context = Sus::It.build(self.class, "test"){}
		
		expect(context.to_s).to be == "it test"
	end
	
	with "unique:" do
		it "can be unique" do
			base = Sus.base
			it = base.it("test", unique: "test"){}
			expect(it.identity).to have_attributes(unique: be == "test")
		end
	end
	
	with "__assertions__" do
		it "counts assertions" do
			assert(true)
			expect(@__assertions__.count).to be == 1
			expect(@__assertions__.passed.size).to be == 2
		end
	end
	
	it "has a class name" do
		skip_unless_method_defined(:set_temporary_name, Module)
		
		expect(self.class.name).to be == "Sus::It[has a class name]"
	end
end
