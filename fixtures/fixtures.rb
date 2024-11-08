# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

module Fixtures
	def fixtures_path(*path)
		File.expand_path(File.join(__dir__, "fixtures", *path))
	end
end
