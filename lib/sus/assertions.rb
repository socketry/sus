
require_relative 'output'

module Sus
	class Assertions
		def self.default(**options)
			self.new(**options, verbose: true)
		end
		
		def initialize(target: nil, output: Output.buffered, inverted: false, isolated: false, verbose: false)
			@target = target
			@output = output
			@inverted = inverted
			@isolated = isolated
			@verbose = verbose
			
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
		
		# Nested assertions that have passed.
		attr :passed
		
		# Nested assertions that have failed.
		attr :failed
		
		# Nested assertions have been deferred.
		attr :deferred
		
		# The total number of assertions performed:
		attr :count
		
		def inspect
			"\#<#{self.class} #{self.object_id} #{@passed.size} passed #{@failed.size} failed #{@deferred.size} deferred>"
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
			# sleep 0.5
			
			@count += 1
			
			if condition
				@passed << self
				
				@output.indented do
					@output.puts(:indent, :passed, pass_prefix, message || "assertion")
				end
			else
				@failed << self
				
				@output.indented do
					@output.puts(:indent, :failed, fail_prefix, message || "assertion")
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
			while block = @deferred.shift
				block.call(self)
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
			output = Output::Buffered.new
			
			output.write(:indent)
			target.print(output)
			output.puts
			
			assertions = self.class.new(target: target, output: output, isolated: isolated, inverted: inverted, **options)
			
			begin
				result = yield(assertions)
			rescue StandardError => error
				assertions.fail(error)
			end
			
			self.add(assertions)
			
			return result
		end
		
		def add(assertions)
			# If the assertions should be an isolated group, make sure any deferred assertions are resolved:
			if assertions.isolated
				assertions.resolve!
			end
			
			if assertions.deferred?
				self.defer do
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
			
			@output.indented do
				@output.append(assertions.output)
			end
		end
		
		def merge!(assertions)
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
		
		def append!(assertions)
			@count += assertions.count
			@passed.concat(assertions.passed)
			@failed.concat(assertions.failed)
			@deferred.concat(assertions.deferred)
			
			if @verbose
				self.print(@output, verbose: false)
				@output.puts
			end
		end
				
		def pass_prefix
			"✓ "
		end
		
		def fail_prefix
			"✗ "
		end
	end
end
