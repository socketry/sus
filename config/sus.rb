require 'covered/config'

def initialize(root, paths)
	super
	
	@covered = Covered::Config.load(root: root)
	if @covered.record?
		@covered.enable
	end
end

def after_tests(assertions)
	super(assertions)
	
	if @covered.record?
		@covered.disable
		@covered.call(self.output.io)
	end
end
