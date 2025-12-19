# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "tmpdir"

module Sus
	module Fixtures
		# Provides a temporary directory context for tests that need isolated file system access.
		module TemporaryDirectoryContext
			# Set up a temporary directory before the test and clean it up after.
			# @yields {|&block| ...} The test block to execute.
			def around(&block)
				Dir.mktmpdir do |root|
					@root = root
					super(&block)
					@root = nil
				end
			end
			
			# @attribute [String] The path to the temporary directory root.
			attr :root
		end
	end
end

