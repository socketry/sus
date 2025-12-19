# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

module Sus
	# Represents a predicate that checks if an object responds to a method.
	class RespondTo
		# Represents a constraint on method parameters.
		class WithParameters
			# Initialize a new WithParameters constraint.
			# @parameter parameters [Array(Symbol)] List of method parameters in the expected order, must include at least all required parameters but can also list optional parameters.
			def initialize(parameters)
				@parameters = parameters
			end
			
			# Evaluate this constraint against method parameters.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Array] The method parameters to check.
			def call(assertions, subject)
				parameters = @parameters.dup
				
				assertions.nested(self) do |assertions|
					expected_name = parameters.shift
					
					subject.each do |type, name|
						case type
						when :req
							assertions.assert(name == expected_name, "parameter #{expected_name} is required, but was #{name}")
						when :opt
							break if expected_name.nil?
							assertions.assert(name == expected_name, "parameter #{expected_name} is specified, but was #{name}")
						else
							break
						end
					end
				end
			end
		end
		
		# Represents a constraint on method keyword options.
		class WithOptions
			# Initialize a new WithOptions constraint.
			# @parameter options [Array(Symbol)] The option names that should be present.
			def initialize(options)
				@options = options
			end
			
			# Print a representation of this constraint.
			# @parameter output [Output] The output target.
			def print(output)
				output.write("with options ", :variable, @options.inspect)
			end
			
			# Evaluate this constraint against method parameters.
			# @parameter assertions [Assertions] The assertions instance to use.
			# @parameter subject [Array] The method parameters to check.
			def call(assertions, subject)
				options = {}
				@options.each{|name| options[name] = nil}
				
				subject.each do |type, name|
					options[name] = type					
				end
				
				assertions.nested(self) do |assertions|
					options.each do |name, type|
						assertions.assert(type != nil, "option #{name}: is required")
					end
				end
			end
		end
		
		# Initialize a new RespondTo predicate.
		# @parameter method [Symbol, String] The method name to check for.
		def initialize(method)
			@method = method
			@parameters = nil
			@options = nil
		end
		
		# Specify that the method should have specific keyword options.
		# @parameter options [Array(Symbol)] The option names that should be present.
		# @returns [RespondTo] Returns self for method chaining.
		def with_options(*options)
			@options = WithOptions.new(options)
			return self
		end
		
		# Print a representation of this predicate.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("respond to ", :variable, @method.to_s, :reset)
		end
		
		# Evaluate this predicate against a subject.
		# @parameter assertions [Assertions] The assertions instance to use.
		# @parameter subject [Object] The subject to evaluate.
		def call(assertions, subject)
			assertions.nested(self) do |assertions|
				condition = subject.respond_to?(@method)
				assertions.assert(condition, self)
				
				if condition and (@parameters or @options)
					parameters = subject.method(@method).parameters
					@parameters.call(assertions, parameters) if @parameters
					@options.call(assertions, parameters) if @options
				end
			end
		end
	end
	
	class Base
		# Create a predicate that checks if the subject responds to a method.
		# @parameter method [Symbol, String] The method name to check for.
		# @returns [RespondTo] A new RespondTo predicate.
		def respond_to(method)
			RespondTo.new(method)
		end
	end
end
