
require_relative 'output'

module Sus
	class Assertions
		def self.default(**options)
			self.new(**options, verbose: true)
		end
		
		def initialize(context: nil, output: Output.default, inverted: false, verbose: false)
			@context = context
			@output = output
			@inverted = inverted
			@verbose = verbose
			
			@passed = Array.new
			@failed = Array.new
			@count = 0
		end
		
		attr :context
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
			
			if verbose && @context
				@context.print(output)
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
			unless @inverted
				@failed.empty?
			else
				@passed.empty? && @failed.any?
			end
		end
		
		def failed?
			!passed?
		end
		
		def assert(condition, message = nil)
			@count += 1
			
			if condition
				@passed << self
				
				if @inverted && message
					@output.puts(:indent, :passed, pass_prefix, message)
				end
			else
				@failed << self
				
				if !@inverted && message
					@output.puts(:indent, :failed, fail_prefix, message)
				end
				
				# require 'debug'
				# binding.debugger(up_level: 0)
			end
		end
		
		def fail(error)
			@failed << self
			
			@output.puts(:indent, :failed, fail_prefix, "Unhandled exception ", :value, error.class, ": ", error.message)
			error.backtrace.each do |line|
				@output.puts(:indent, line)
			end
		end
		
		def nested(context, isolated: false, **options)
			result = nil
			output = @output
			
			if isolated
				output = Output::Buffered.new(output)
			end
			
			output.write(:indent)
			context.print(output)
			output.puts
			
			assertions = self.class.new(context: context, output: output, **options)
			
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
				if @inverted
					@output.write(:indent, :failed, fail_prefix, :reset)
					self.print(@output, verbose: false)
					@output.puts
				elsif @verbose
					@output.write(:indent, :passed, pass_prefix, :reset)
					self.print(@output, verbose: false)
					@output.puts
				end
			else
				@failed << assertions
				if !@inverted
					@output.write(:indent, :failed, fail_prefix, :reset)
					self.print(@output, verbose: false)
					@output.puts
				elsif @verbose
					@output.write(:indent, :passed, pass_prefix, :reset)
					self.print(@output, verbose: false)
					@output.puts
				end
			end
		end
		
		def add(assertions)
			@count += assertions.count
			
			unless assertions.inverted
				@passed.concat(assertions.passed)
				@failed.concat(assertions.failed)
			else
				@passed.concat(assertions.failed)
				@failed.concat(assertions.passed)
			end
			
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
