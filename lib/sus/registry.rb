# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'base'

require_relative 'file'
require_relative 'describe'
require_relative 'with'

require_relative 'it'

require_relative 'shared'
require_relative 'it_behaves_like'
require_relative 'include_context'

require_relative 'let'

module Sus
	class Registry
		GLOB_MATCHER = "**/*.rb"

		# Create a top level scope with self as the instance:
		def initialize(base = Sus.base(self))
			@base = base
		end

		attr :base

		def print(output)
			output.write("Test Registry")
		end

		def load(path)
			if Pathname.new(path).directory?
				load_directory(path)
			else
				@base.file(path)
			end
		end

		def load_directory(path)
			Dir.glob("#{path}/#{GLOB_MATCHER}").each do |file_path|
				load(file_path)
			end
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
