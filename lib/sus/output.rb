
require_relative 'output/bar'
require_relative 'output/text'
require_relative 'output/xterm'

require_relative 'output/null'
require_relative 'output/progress'

module Sus
	module Output
		def self.for(io)
			if io.isatty
				XTerm.new(io)
			else
				Text.new(io)
			end
		end
		
		def self.default(io = $stderr)
			output = self.for(io)
			
			Output::Bar.register(output)
			
			output[:context] = output.style(nil, nil, :bold)
			
			output[:describe] = output.style(:cyan, nil, :bold)
			output[:it] = output.style(:cyan)
			output[:with] = output.style(:cyan)
			
			output[:variable] = output.style(:blue, nil, :bold)
			
			output[:passed] = output.style(:green, nil, :bold)
			output[:failed] = output.style(:red, nil, :bold)
			
			return output
		end
		
		def self.buffered
			Buffered.new
		end
	end
end
