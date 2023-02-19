# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.
# Copyright, 2022, by Brad Schrag.

require_relative 'context'

# This has to be done at the top level. It allows us to define constants within the given class while still retaining top-level constant resolution.
Sus::TOPLEVEL_CLASS_EVAL = ->(__klass__, __path__){__klass__.class_eval(::File.read(__path__), __path__)}

module Sus
	module File
		extend Context
		
		def self.extended(base)
			base.children = Hash.new
		end
		
		def self.build(parent, path)
			base = Class.new(parent)
			base.extend(File)
			base.description = path
			base.identity = Identity.new(path)
			
			TOPLEVEL_CLASS_EVAL.call(base, path)
			
			return base
		end
		
		def print(output)
			output.write("file ", :path, self.identity)
		end
	end
	
	class FileLoadError
		def self.build(parent, path, error)
			self.new(Identity.new(path, path, 1), path, error)
		end
		
		def initialize(identity, path, error)
			@identity = identity
			@path = path
			@error = error
		end
		
		attr :identity
		
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
		rescue StandardError, LoadError, SyntaxError => error
			add FileLoadError.build(self, path, error)
		end
	end
end
