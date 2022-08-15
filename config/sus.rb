$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require 'covered/config'

def initialize(root, paths)
	super
	
	@covered = Covered::Config.load
	@covered&.enable
end

def after_tests(assertions)
	super(assertions)
	
	@covered&.disable
	@covered&.call(self.output.io)
end
