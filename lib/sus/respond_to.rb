# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Sus
	class RespondTo
		class WithParameters
			# @parameter [Array(Symbol)] List of method parameters in the expected order, must include at least all required parameters but can also list optional parameters.
			def initialize(parameters)
				@parameters = parameters
			end
			
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
		
		class WithOptions
			def initialize(options)
				@options = options
			end
						
			def print(output)
				output.write("with options ", :variable, @options.inspect)
			end
			
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
		
		def initialize(method)
			@method = method
			@parameters = nil
			@options = nil
		end
		
		def with_options(*options)
			@options = WithOptions.new(options)
			return self
		end
		
		def print(output)
			output.write("respond to ", :variable, @method.to_s, :reset)
		end
		
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
		def respond_to(method)
			RespondTo.new(method)
		end
	end
end
