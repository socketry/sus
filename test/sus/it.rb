
describe Sus::It do
	let(:buffered_assertions) {Sus::Assertions.new(Sus::Terminal.buffered)}
	
	attr_accessor :before_hook_invoked
	attr_accessor :after_hook_invoked
	
	def before
		self.before_hook_invoked = true
	end
	
	def after
		self.after_hook_invoked = true
	end
	
	let(:subject) do
		Sus::It.build(self.class, "test") do
			self
		end
	end
	
	it "invokes before hook" do
		instance = subject.call(buffered_assertions)
		
		assert(instance.before_hook_invoked)
	end
	
	it "invokes after hook" do
		instance = subject.call(buffered_assertions)
		
		assert(instance.after_hook_invoked)
	end
end
