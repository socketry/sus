# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'covered/config'

def initialize(...)
	super
	
	@covered = Covered::Config.load(root: self.root)
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
