
require_relative 'output'

module Sus
	class Assertions
		def self.default(**options)
			self.new(**options, verbose: true)
		end
		
		def initialize(target: nil, output: Output.default, inverted: false, verbose: false)
			@target = target
			@output = output
			@inverted = inverted
			@verbose = verbose
			
			@passed = Array.new
			@failed = Array.new
			@count = 0
		end
		
		attr :target
		attr :output
		attr :level
		attr :inverted
		attr :verbose
		
		# How many nested assertions passed.
		attr :passed
		
		# How many nested assertions failed.
		attr :failed
		
		# The total number of assertions performed:
		attr :count
		
		def inspect
			"\#<#{self.class} #{@passed.size} passed #{@failed.size} failed>"
		end
		
		def total
			@passed.size + @failed.size
		end
		
		def print(output, verbose: @verbose)
			self
			
			if verbose && @target
				@target.print(output)
				output.write(": ")
			end
			
			if @count.zero?
				output.write("0 assertions")
			else
				if @passed.any?
					output.write(:passed, @passed.size, " passed", :reset, " ")
				end
				
				if @failed.any?
					output.write(:failed, @failed.size, " failed", :reset, " ")
				end
				
				output.write("out of ", self.total, " total (", @count, " assertions)")
			end
		end
		
		def puts(*message)
			@output.puts(:indent, *message)
		end
		
		def passed?
			@failed.empty?
		end
		
		def failed?
			@failed.any?
		end
		
		def assert(condition, message = nil)
			@count += 1
			
			if @inverted
				condition = !condition
			end
			
			if condition
				@passed << self
				
				if @verbose
					@output.puts(:indent, :passed, pass_prefix, message || "assertion")
				end
			else
				@failed << self
				
				@output.puts(:indent, :failed, fail_prefix, message || "assertion")
			end
		end
		
		def fail(error)
			@failed << self
			
			@output.puts(:indent, :failed, fail_prefix, "Unhandled exception ", :value, error.class, ": ", error.message)
			error.backtrace.each do |line|
				@output.puts(:indent, line)
			end
		end
		
		def nested(target, isolated: false, inverted: false, **options)
			result = nil
			output = @output
			
			if inverted
				inverted = !@inverted
			else
				inverted = @inverted
			end
			
			if isolated
				output = Output::Buffered.new(output)
			end
			
			output.write(:indent)
			target.print(output)
			output.puts
			
			assertions = self.class.new(target: target, output: output, inverted: inverted, **options)
			
			begin
				output.indented do
					result = yield(assertions)
				end
			rescue StandardError => error
				assertions.fail(error)
			end
			
			if assertions
				if isolated
					merge(assertions)
				else
					add(assertions)
				end
			end
			
			return result
		end
		
		def merge(assertions)
			@count += assertions.count
			
			if assertions.passed?
				@passed << assertions

				if @verbose
					@output.write(:indent, :passed, pass_prefix, :reset)
					self.print(@output, verbose: false)
					@output.puts
				end
			else
				@failed << assertions

				@output.write(:indent, :failed, fail_prefix, :reset)
				self.print(@output, verbose: false)
				@output.puts
			end
		end
		
		def add(assertions)
			@count += assertions.count
			@passed.concat(assertions.passed)
			@failed.concat(assertions.failed)
			
			if @verbose
				self.print(@output, verbose: false)
				@output.puts
			end
		end
		
		private
		
		def pass_prefix
			"✓ "
		end
		
		def fail_prefix
			"✗ "
		end
	end
end
