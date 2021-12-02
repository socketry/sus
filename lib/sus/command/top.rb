require 'samovar'
require_relative 'run'
require_relative 'sequential'
require_relative 'list'

module Sus
	module Command
		class Top < Samovar::Command
			self.description = "Test your code."
			
			nested :command, {
				'run' => Run,
				'sequential' => Sequential,
				'list' => List,
			}, default: 'run'
			
			def call
				if command = self.command
					command.call
				else
					self.print_usage
				end
			end
		end
	end
end
