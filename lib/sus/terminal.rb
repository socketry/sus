
require_relative 'terminal/text'
require_relative 'terminal/xterm'

module Sus
	module Terminal
		def self.for(io)
			if io.isatty
				XTerm.new(io)
			else
				Text.new(io)
			end
		end
		
		def self.default(io = $stderr)
			terminal = self.for(io)
			
			Terminal::Bar.register(terminal)
			
			terminal[:context] = terminal.style(nil, nil, :bold)
			
			terminal[:describe] = terminal.style(:cyan, nil, :bold)
			terminal[:it] = terminal.style(:cyan)
			terminal[:with] = terminal.style(:cyan)
			
			terminal[:variable] = terminal.style(:blue, nil, :bold)
			
			terminal[:passed] = terminal.style(:green, nil, :bold)
			terminal[:failed] = terminal.style(:red, nil, :bold)
			
			return terminal
		end
		
		def self.buffered(io = StringIO.new)
			Text.new(io)
		end
	end
end
