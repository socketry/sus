# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.
# Copyright, 2022, by Brad Schrag.

require_relative "context"

# This has to be done at the top level. It allows us to define constants within the given class while still retaining top-level constant resolution.
Sus::TOPLEVEL_CLASS_EVAL = ->(__klass__, __path__){__klass__.class_eval(::File.read(__path__), __path__)}

# This is a hack to allow us to get the line number of a syntax error.
unless SyntaxError.method_defined?(:lineno)
	class SyntaxError
		def lineno
			if message =~ /:(\d+):/
				$1.to_i
			end
		end
	end
end

module Sus
	module File
		extend Context
		
		def self.[] path
			self.build(Sus.base, path)
		end
		
		def self.extended(base)
			base.children = Hash.new
		end
		
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
		
		def print(output)
			output.write("file ", :path, self.identity, :reset)
		end
	end
	
	class FileLoadError
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
		
		def initialize(identity, path, error)
			@identity = identity
			@path = path
			@error = error
		end
		
		attr :identity
		attr :error
		
		def leaf?
			true
		end
		
		EMPTY = Hash.new.freeze
		
		def children
			EMPTY
		end
		
		def description
			@path
		end
		
		def print(output)
			output.write("file ", :path, @identity)
		end
		
		def call(assertions)
			assertions.nested(self, identity: @identity, isolated: true) do |assertions|
				assertions.error!(@error)
			end
		end
	end
	
	private_constant :FileLoadError
	
	module Context
		def file(path)
			add File.build(self, path)
		end
	end
end
