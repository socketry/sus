module Fixtures
	def fixtures_path(*path)
		File.expand_path(File.join(__dir__, 'fixtures', *path))
	end
end
