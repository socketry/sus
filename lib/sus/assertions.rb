
require_relative 'terminal'
require_relative 'failure'

module Sus
	class Assertions
		def initialize(context: nil, output: Terminal.default, level: 0, inverted: false, verbose: false)
			@context = context
			@output = output
			@level = level
			@inverted = inverted
			@verbose = verbose
			
			@passed = 0
			@failed = 0
			@count = 0
		end
		
		attr :context
		attr :output
		attr :level
		attr :inverted
		attr :verbose
		
		attr :passed
		attr :failed
		attr :count
		
		def total
			@passed + @failed
		end
		
		def print(output, verbose: @verbose)
			if verbose && @context
				@context.print(output)
				output.print(": ")
			end
			
			if @passed > 0
				output.print(:passed, @passed, " passed", :reset, " ")
			end
			
			if @failed > 0
				output.print(:failed, @failed, " failed", :reset, " ")
			end
			
			output.print("out of ", self.total, " total (", @count, " assertions)")
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
		
		def failed?
			!passed?
		end
		
		def assert(condition, message = nil)
			@count += 1
			
			if condition
				@passed += 1
				
				if @inverted && message
					@output.print_line(indent, :passed, pass_prefix, message)
				end
			else
				@failed += 1
				
				if !@inverted && message
					@output.print_line(indent, :failed, fail_prefix, message)
				end
			end
		end
		
		def refute(condition)
			assert(!condition)
		end
		
		def fail(error)
			@failed += 1
			@output.print_line(indent, :failed, fail_prefix, "Unhandled exception ", :value, error.class, ": ", error.message)
			error.backtrace.each do |line|
				@output.print_line(indent, line)
			end
		end
		
		def nested(context, **options)
			@output.print(indent)
			context.print(@output)
			@output.print_line
			
			# if @context && context
				level = @level + 1
			# else
				# level = @level
			# end
			
			assertions = self.class.new(context: context, output: @output, level: level, **options)
			
			begin
				result = yield(assertions)
			rescue StandardError => error
				assertions.fail(error)
			end
			
			add(assertions) if assertions
			
			return result
		end
		
		def add(assertions)
			@count += assertions.count
			
			if assertions.passed?
				@passed += 1
				if @inverted
					@output.print(indent, :failed, fail_prefix, :reset)
					self.print(@output, verbose: false)
					@output.print_line
				elsif @verbose
					@output.print(indent, :passed, pass_prefix, :reset)
					self.print(@output, verbose: false)
					@output.print_line
				end
			else
				@failed += 1
				if !@inverted
					@output.print(indent, :failed, fail_prefix, :reset)
					self.print(@output, verbose: false)
					@output.print_line
				elsif @verbose
					@output.print(indent, :passed, pass_prefix, :reset)
					self.print(@output, verbose: false)
					@output.print_line
				end
			end
		end
	end
end
