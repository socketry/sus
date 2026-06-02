# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2026, by Samuel Williams.

require_relative "output/bar"
require_relative "output/text"
require_relative "output/xterm"

require_relative "output/null"
require_relative "output/progress"

module Sus
	# Represents output handlers for test results and messages.
	module Output
		# Detect if we're running in GitHub Actions, where human-readable output is preferred.
		# GitHub Actions sets the GITHUB_ACTIONS environment variable to "true".
		# @parameter env [Hash] The environment variables to check.
		def self.github_actions?(env)
			env["GITHUB_ACTIONS"] == "true"
		end
		
		# Create an appropriate output handler for the given IO.
		# @parameter io [IO] The IO object to write to.
		# @parameter env [Hash] The environment variables to consider (defaults to ENV).
		# @returns [XTerm, Text] An XTerm handler if the IO is a TTY or running in GitHub Actions, otherwise a Text handler.
		def self.for(io, env = ENV)
			if io.isatty or self.github_actions?(env)
				XTerm.new(io)
			else
				Text.new(io)
			end
		end
		
		# Create a default output handler with styling configured.
		# @parameter io [IO] The IO object to write to (defaults to $stderr).
		# @parameter env [Hash] The environment variables to consider (defaults to ENV).
		# @returns [XTerm, Text] A configured output handler.
		def self.default(io = $stderr, env = ENV)
			output = self.for(io, env)
			
			Output::Bar.register(output)
			
			output[:context] = output.style(nil, nil, :bold)
			
			output[:describe] = output.style(:cyan)
			output[:it] = output.style(:cyan)
			output[:with] = output.style(:cyan)
			
			output[:variable] = output.style(:blue, nil, :bold)
			
			# Syntax highlighting for inspected values:
			output[:literal_string] = output.style(:green)
			output[:literal_number] = output.style(:magenta)
			output[:literal_symbol] = output.style(:cyan)
			output[:literal_keyword] = output.style(:blue, nil, :bold)
			
			output[:path] = output.style(:yellow)
			output[:line] = output.style(:yellow)
			output[:identity] = output.style(:yellow)
			
			output[:passed] = output.style(:green)
			output[:failed] = output.style(:red)
			output[:deferred] = output.style(:yellow)
			output[:skipped] = output.style(:blue)
			output[:errored] = output.style(:red)
			# output[:inform] = output.style(nil, nil, :bold)
			
			return output
		end
		
		# Create a buffered output handler.
		# @returns [Buffered] A new buffered output handler.
		def self.buffered
			Buffered.new
		end
	end
end
