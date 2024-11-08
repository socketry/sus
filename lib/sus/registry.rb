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
	class Registry
		DIRECTORY_GLOB = "**/*.rb"
		
		# Create a top level scope with self as the instance:
		def initialize(**options)
			@base = Sus.base(self, **options)
			@loaded = {}
		end
		
		attr :base
		
		def print(output)
			output.write("Test Registry")
		end
		
		def to_s
			@base&.identity&.to_s || self.class.name
		end
		
		def load(path)
			if ::File.directory?(path)
				load_directory(path)
			else
				load_file(path)
			end
		end
		
		private def load_file(path)
			@loaded[path] ||= @base.file(path)
		end
		
		private def load_directory(path)
			::Dir.glob(::File.join(path, DIRECTORY_GLOB), &self.method(:load_file))
		end
		
		def call(assertions = Assertions.default)
			@base.call(assertions)
			
			return assertions
		end
		
		def each(...)
			@base.each(...)
		end
		
		def children
			@base.children
		end
	end
end
