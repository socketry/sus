# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.
# Copyright, 2022, by Brad Schrag.

require_relative "context"

# This has to be done at the top level. It allows us to define constants within the given class while still retaining top-level constant resolution.
Sus::TOPLEVEL_CLASS_EVAL = ->(__klass__, __path__){__klass__.class_eval(::File.read(__path__), __path__)}

# This is a hack to allow us to get the line number of a syntax error.
unless SyntaxError.method_defined?(:lineno)
	# Extension to SyntaxError to extract line numbers from error messages.
	class SyntaxError
		# Extract the line number from the error message.
		# @returns [Integer, nil] The line number if found in the message.
		def lineno
			if message =~ /:(\d+):/
				$1.to_i
			end
		end
	end
end

module Sus
	# Represents a test file that can be loaded and executed.
	module File
		extend Context
		
		# Load a test file.
		# @parameter path [String] The path to the test file.
		# @returns [Class] A test class representing the file.
		def self.[] path
			self.build(Sus.base, path)
		end
		
		# Called when this module is extended.
		# @parameter base [Class] The class being extended.
		def self.extended(base)
			base.children = Hash.new
		end
		
		# Build a test class from a file path.
		# @parameter parent [Class] The parent context class.
		# @parameter path [String] The path to the test file.
		# @returns [Class] A test class representing the file.
		def self.build(parent, path)
			base = Class.new(parent)
			
			base.extend(File)
			base.description = path
			base.identity = Identity.file(parent.identity, path)
			base.set_temporary_name("#{self}[#{path}]")
			
			begin
				TOPLEVEL_CLASS_EVAL.call(base, path)
			rescue StandardError, LoadError, SyntaxError => error
				# We add this as a child of the base class so that it is included in the tree under the file rather than completely replacing it, which can be confusing:
				base.add FileLoadError.build(self, path, error)
			end
			
			return base
		end
		
		# Print a representation of this file context.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("file ", :path, self.identity, :reset)
		end
	end
	
	# Represents an error that occurred while loading a test file.
	class FileLoadError
		# Build a new FileLoadError.
		# @parameter parent [Object] The parent context.
		# @parameter path [String] The path to the file that failed to load.
		# @parameter error [Exception] The error that occurred.
		# @returns [FileLoadError] A new FileLoadError instance.
		def self.build(parent, path, error)
			identity = Identity.file(parent.identity, path)
			
			# This is a mess.
			if error.is_a?(SyntaxError) and error.path == path
				identity = identity.with_line(error.lineno)
			else
				identity = identity.scoped(error.backtrace_locations)
			end
			
			self.new(identity, path, error)
		end
		
		# Initialize a new FileLoadError.
		# @parameter identity [Identity] The identity where the error occurred.
		# @parameter path [String] The path to the file.
		# @parameter error [Exception] The error that occurred.
		def initialize(identity, path, error)
			@identity = identity
			@path = path
			@error = error
		end
		
		# @attribute [Identity] The identity where the error occurred.
		attr :identity
		
		# @attribute [Exception] The error that occurred.
		attr :error
		
		# @returns [Boolean] Always returns true, as errors are leaf nodes.
		def leaf?
			true
		end
		
		# An empty hash used for children.
		EMPTY = Hash.new.freeze
		
		# @returns [Hash] Always returns an empty hash.
		def children
			EMPTY
		end
		
		# @returns [String] The file path.
		def description
			@path
		end
		
		# Print a representation of this error.
		# @parameter output [Output] The output target.
		def print(output)
			output.write("file ", :path, @identity)
		end
		
		# Execute this error, recording it in assertions.
		# @parameter assertions [Assertions] The assertions instance.
		def call(assertions)
			assertions.nested(self, identity: @identity, isolated: true) do |assertions|
				assertions.error!(@error)
			end
		end
	end
	
	private_constant :FileLoadError
	
	module Context
		# Load a test file as a child context.
		# @parameter path [String] The path to the test file.
		def file(path)
			add File.build(self, path)
		end
	end
end
