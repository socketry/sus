# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'context'

# This has to be done at the top level. It allows us to define constants within the given class while still retaining top-level constant resolution.
Sus::TOPLEVEL_CLASS_EVAL = ->(klass, path){klass.class_eval(::File.read(path), path)}

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
	
	module Context
		def file(path)
			add File.build(self, path)
		end
	end
end
