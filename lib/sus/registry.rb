# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.
# Copyright, 2022, by Brad Schrag.

require_relative "base"

require_relative "file"
require_relative "describe"
require_relative "with"

require_relative "it"

require_relative "shared"
require_relative "it_behaves_like"
require_relative "include_context"

require_relative "let"

module Sus
	# Represents a registry of test files and contexts.
	class Registry
		# The glob pattern used to find Ruby files in directories.
		DIRECTORY_GLOB = "**/*.rb"
		
		# Initialize a new registry.
		# @parameter options [Hash] Options to pass to the base context.
		def initialize(**options)
			@base = Sus.base(self, **options)
			@loaded = {}
		end
		
		# @attribute [Class] The base test context class.
		attr :base
		
		# Print a representation of this registry.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("Test Registry")
		end
		
		# @returns [String] A string representation of this registry.
		def to_s
			@base&.identity&.to_s || self.class.name
		end
		
		# Load a test file or directory.
		# @parameter path [String] The path to load (file or directory).
		def load(path)
			if ::File.directory?(path)
				load_directory(path)
			else
				load_file(path)
			end
		end
		
		# Load a single test file.
		# @parameter path [String] The path to the test file.
		private def load_file(path)
			@loaded[path] ||= @base.file(path)
		end
		
		# Load all Ruby files in a directory.
		# @parameter path [String] The directory path.
		private def load_directory(path)
			::Dir.glob(::File.join(path, DIRECTORY_GLOB), &self.method(:load_file))
		end
		
		# Execute all tests in the registry.
		# @parameter assertions [Assertions] Optional assertions instance to use.
		# @returns [Assertions] The assertions instance with results.
		def call(assertions = Assertions.default)
			@base.call(assertions)
			
			return assertions
		end
		
		# Iterate over all test cases in the registry.
		# @yields {|test| ...} Each test case.
		def each(...)
			@base.each(...)
		end
		
		# @returns [Hash] The child contexts and tests.
		def children
			@base.children
		end
	end
end
