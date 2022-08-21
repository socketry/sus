module Sus
	module Loader
		def require_library(path)
			require(::File.join(self.require_root, "lib", path))
		end
		
		def require_fixture(path)
			require(::File.join(self.require_root, "fixtures", path))
		end
	end
end
