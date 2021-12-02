require 'etc'
require 'samovar'

module Sus
	module Command
		class List < Samovar::Command
			self.description = "List all available tests."
			
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
			
			def call
				registry = Sus::Registry.new
				output = Sus::Terminal.default
				
				prepare(registry)
				
				registry.each do |child|
					child.print(output)
					output.print_line
				end
			end
		end
	end
end
