require 'etc'
require 'samovar'

module Sus
	module Command
		class Sequential < Samovar::Command
			self.description = "Run one or more tests."
			
			many :paths
			
			def prepare(registry)
				if paths&.any?
					paths.each do |path|
						registry.load(path)
					end
				else
					Dir.glob("test/**/*.rb").each do |path|
						registry.load(path)
					end
				end
			end
			
			Result = Struct.new(:job, :assertions)
			
			def call
				registry = Sus::Registry.new
				output = Sus::Output.default

				prepare(registry)

				registry.call
			end
		end
	end
end
