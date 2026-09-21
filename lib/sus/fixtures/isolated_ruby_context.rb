# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "rbconfig"

# @namespace
module Sus
	# @namespace
	module Fixtures
		# Evaluates Ruby in a fresh process and returns its result through Marshal.
		module IsolatedRubyContext
			# Raised when the child process exits unsuccessfully without returning an exception.
			class Error < RuntimeError
				# @parameter status [Process::Status] The child process's exit status.
				def initialize(status)
					@status = status
					super("Isolated Ruby failed (#{status})")
				end
				
				# @attribute [Process::Status] The child process's exit status.
				attr :status
			end
			
			# Evaluate source using the current Ruby interpreter, without sharing Ruby state or changing the caller's working directory.
			# The final expression is serialized with Marshal.dump and restored with Marshal.load. Printed output goes to the inherited stderr.
			# Exceptions are marshaled back and re-raised with their original backtraces. SystemExit follows the child process's exit status.
			# @parameter source [String] Ruby source code to evaluate.
			# @parameter chdir [String] The child process's working directory.
			# @parameter env [Hash(String, String | Nil)] Child environment overrides; nil removes a variable. The environment is inherited by default, including RUBYOPT for coverage hooks.
			# @parameter requires [Array(String)] Features to require before evaluating source, such as bundler/setup.
			# @returns [Object] The unmarshaled result, or nil if the child exits successfully without a result. Classes used by the result must be available in the caller.
			# @raises [Exception] The exception raised in the child process, if it can be marshaled back.
			# @raises [Error] If the child exits unsuccessfully without returning an exception.
			# @raises [ArgumentError] If the result or exception uses a class unavailable in the caller.
			def isolated_ruby(source, chdir: Dir.pwd, env: {}, requires: [])
				script = <<~'RUBY'
					->(output) do
						$stdout.reopen($stderr)
						begin
							source = $stdin.read
							ARGV.each{|feature| require feature}
							result = eval(source, TOPLEVEL_BINDING, File.join(Dir.pwd, "(isolated ruby)"))
							output.write(Marshal.dump([result, nil]))
						rescue SystemExit
							raise
						rescue Exception => error
							output.write(Marshal.dump([nil, error]))
						end
					end.call($stdout.dup.binmode)
				RUBY
				
				output = IO.popen([env, RbConfig.ruby, "-e", script, "--", *requires], "r+b", chdir: chdir) do |process|
					begin
						process.write(source)
					rescue Errno::EPIPE
						# A startup failure may close stdin before accepting the source:
					end
					process.close_write
					process.read
				end
				status = $?
				raise Error.new(status) unless status.success?
				return nil if output.empty?
				
				result, error = Marshal.load(output)
				raise error if error
				result
			end
		end
	end
end
