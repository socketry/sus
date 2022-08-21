
require_relative 'output'
require_relative 'clock'

require_relative 'output/backtrace'

module Sus
	class Assertions
		def self.default(**options)
			self.new(**options)
		end
		
		def initialize(identity: nil, target: nil, output: Output.buffered, inverted: false, isolated: false, measure: false, verbose: false)
			# In theory, the target could carry the identity of the assertion group, but it's not really necessary, so we just handle it explicitly and pass it into any nested assertions.
			@identity = identity
			@target = target
			@output = output
			@inverted = inverted
			@isolated = isolated
			@verbose = verbose
			
			if measure
				@clock = Clock.new
			else
				@clock = nil
			end
			
			@passed = Array.new
			@failed = Array.new
			@deferred = Array.new
			
			@count = 0
		end
		
		attr :target
		attr :output
		attr :level
		attr :inverted
		attr :isolated
		attr :verbose
		
		attr :clock
		
		# Nested assertions that have passed.
		attr :passed
		
		# Nested assertions that have failed.
		attr :failed
		
		# Nested assertions have been deferred.
		attr :deferred
		
		# The total number of assertions performed:
		attr :count
		
		def inspect
			"\#<#{self.class} #{@passed.size} passed #{@failed.size} failed #{@deferred.size} deferred>"
		end
		
		def total
			@passed.size + @failed.size
		end
		
		def print(output, verbose: @verbose)
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
				
				if @deferred.any?
					output.write(:deferred, @deferred.size, " deferred", :reset, " ")
				end
				
				output.write("out of ", self.total, " total (", @count, " assertions)")
			end
		end
		
		def puts(*message)
			@output.puts(:indent, *message)
		end
		
		def empty?
			@passed.empty? and @failed.empty?
		end
		
		def passed?
			if @inverted
				# Inverted assertions:
				self.failed.any?
			else
				# Normal assertions:
				self.failed.empty?
			end
		end
		
		def failed?
			!self.passed?
		end
		
		def assert(condition, message = nil)
			@count += 1
			
			if condition
				@passed << self
				
				if @inverted || @verbose
					@output.puts(:indent, :passed, pass_prefix, message || "assertion", Output::Backtrace.first(@identity))
				end
			else
				@failed << self
				
				if !@inverted || @verbose
					@output.puts(:indent, :failed, fail_prefix, message || "assertion", Output::Backtrace.first(@identity))
				end
			end
		end
		
		# Add deferred assertions.
		def defer(&block)
			@deferred << block
		end
		
		# Whether there are any deferred assertions.
		def deferred?
			@deferred.any?
		end
		
		# This resolves all deferred assertions in order.
		def resolve!
			@output.indented do
				while block = @deferred.shift
					block.call(self)
				end
			end
		end
		
		def fail(error)
			@failed << self
			
			lines = error.message.split(/\r?\n/)
			
			@output.puts(:indent, :error, fail_prefix, "Unhandled exception ", :value, error.class, ":", :reset, " ", lines.shift)
			
			lines.each do |line|
				@output.puts(:indent, "| ", line)
			end
				
			@output.write(Output::Backtrace.for(error, @identity))
		end
		
		def nested(target, identity: @identity, isolated: false, inverted: false, **options)
			result = nil
			
			# Isolated assertions need to have buffered output so they can be replayed if they fail:
			if isolated
				output = @output.buffered
			else
				output = @output
			end
			
			output.puts(:indent, target)
			
			assertions = self.class.new(identity: identity, target: target, output: output, isolated: isolated, inverted: inverted, verbose: @verbose, **options)
			
			@clock&.start!

			output.indented do
				begin
					result = yield(assertions)
				rescue StandardError => error
					assertions.fail(error)
				ensure
					@clock&.stop!
				end
			end
			
			self.add(assertions)
			
			return result
		end
		
		def add(assertions)
			# If the assertions should be an isolated group, make sure any deferred assertions are resolved:
			if assertions.isolated and assertions.deferred?
				assertions.resolve!
			end
			
			if assertions.deferred?
				self.defer do
					output.puts(:indent, assertions.target)
					assertions.resolve!
					
					self.add!(assertions)
				end
			else
				self.add!(assertions)
			end
		end
		
		private
		
		def add!(assertions)
			raise "Nested assertions must be fully resolved!" if assertions.deferred?
			
			if assertions.isolated or assertions.inverted
				# If we are isolated, we merge all child assertions into the parent as a single entity:
				merge!(assertions)
			else
				# Otherwise, we append all child assertions into the parent assertions:
				append!(assertions)
			end
		end
		
		def merge!(assertions)
			@count += assertions.count
			
			if assertions.passed?
				@passed << assertions

				# if @verbose
				# 	@output.write(:indent, :passed, pass_prefix, :reset)
				# 	self.print(@output, verbose: false)
				# 	@output.puts
				# end
			else
				@failed << assertions

				# @output.write(:indent, :failed, fail_prefix, :reset)
				# self.print(@output, verbose: false)
				# @output.puts
			end
		end
		
		def append!(assertions)
			@count += assertions.count
			@passed.concat(assertions.passed)
			@failed.concat(assertions.failed)
			@deferred.concat(assertions.deferred)
			
			# if @verbose
			# 	@output.write(:indent)
			# 	self.print(@output, verbose: false)
			# 	@output.puts
			# end
		end
				
		def pass_prefix
			"✓ "
		end
		
		def fail_prefix
			"✗ "
		end
	end
end
