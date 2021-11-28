
require_relative 'terminal'

module Sus
	class Assertions
		attr :output
		attr :level
		attr :inverted
		attr :verbose
		
		attr :passed
		attr :failed
		attr :count
		
		def initialize(output = Terminal.default, level: 0, inverted: false, verbose: false)
			@output = output
			@level = level
			@inverted = inverted
			@verbose = verbose
			
			@passed = 0
			@failed = 0
			@count = 0
		end
		
		def total
			@passed + @failed
		end
		
		def print(output)
			output.print(:passed, @passed, " passed", :reset)
			
			if @failed > 0
				output.print(" ", :failed, @failed, " failed", :reset)
			end
			
			output.print(" out of ", self.total, " total (", @count, " assertions)")
		end
		
		def pass_prefix
			"✓ "
		end
		
		def fail_prefix
			"✗ "
		end
		
		def indent
			"\t" * @level
		end
		
		def print_line(*message)
			@output.print_line(indent, *message)
		end 
		
		def passed?
			unless @inverted
				@failed.zero?
			else
				@passed.zero? && @failed > 0
			end
		end
		
		def assert(condition, function = nil)
			@count += 1
			
			if condition
				@passed += 1
				
				if @inverted && function
					@output.print_line(indent, :passed, pass_prefix, function)
				end
			else
				@failed += 1
				
				if !@inverted && function
					@output.print_line(indent, :failed, fail_prefix, function)
				end
			end
		end
		
		def refute(condition)
			assert(!condition)
		end
		
		def nested(function, **options)
			@output.print(indent)
			function.print(@output)
			@output.print_line
			
			assertions = self.class.new(@output, level: @level+1, **options)
			
			yield assertions
			
			@count += assertions.count
			
			if assertions.passed?
				@passed += 1
				if @inverted
					@output.print(indent, :failed, fail_prefix, :reset, function.description)
					if @verbose
						@output.print(": ")
						assertions.print(@output)
					end
					
					@output.print_line
				elsif @verbose
					@output.print(indent, :passed, pass_prefix, :reset, function.description, ": ")
					assertions.print(@output)
					@output.print_line
				end
			else
				@failed += 1
				if !@inverted
					@output.print(indent, :failed, fail_prefix, :reset, function.description)
					if @verbose
						@output.print(": ")
						assertions.print(@output)
					end
					
					@output.print_line
				elsif @verbose
					@output.print(indent, :passed, pass_prefix, :reset, function.description, ": ")
					assertions.print(@output)
					@output.print_line
				end
			end
		end
	end
end
