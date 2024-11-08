# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	class Identity
		def self.file(parent, path, name = path, **options)
			self.new(path, name, nil, nil, **options)
		end
		
		def self.nested(parent, name, location = nil, **options)
			location ||= caller_locations(3...4).first
			
			self.new(location.path, name, location.lineno, parent, **options)
		end
		
		def self.current
			self.nested(nil, nil, caller_locations(1...2).first)
		end
		
		# @parameter unique [Boolean | Symbol] Whether this identity is unique or needs a unique key/line number suffix.
		def initialize(path, name = nil, line = nil, parent = nil, unique: true)
			@path = path
			@name = name
			@line = line
			@parent = parent
			@unique = unique
			
			@key = nil
		end
		
		def with_line(line)
			self.class.new(@path, @name, line, @parent, unique: @unique)
		end
		
		attr :path
		attr :name
		attr :line
		attr :parent
		attr :unique
		
		def to_s
			self.key
		end
		
		def to_location
			{
				path: ::File.expand_path(@path),
				line: @line,
			}
		end
		
		def inspect
			"\#<#{self.class} #{self.to_s}>"
		end
		
		def match?(other)
			if path = other.path
				return false unless path === @path
			end
			
			if name = other.name
				return false unless name === @name
			end
			
			if line = other.line
				return false unless line === @line
			end
		end
		
		def each(&block)
			@parent&.each(&block)
			
			yield self
		end
		
		def key
			unless @key
				key = Array.new
				
				# For a specific leaf node, the last part is not unique, i.e. it must be identified explicitly.
				append_unique_key(key, @unique == true ? false : @unique)
				
				@key = key.join(":")
			end
			
			return @key
		end
		
		# Given a set of locations, find the first one which matches this identity and return a new identity with the updated line number. This can be used to extract a location from a backtrace.
		def scoped(locations = nil)
			if locations
				# This code path is normally taken if we've got an exception with a backtrace:
				locations.each do |location|
					if location.path == @path
						return self.with_line(location.lineno)
					end
				end
			else
				# In theory this should be a bit faster:
				each_caller_location do |location|
					if location.path == @path
						return self.with_line(location.lineno)
					end
				end
			end
			
			return self
		end
		
		protected
		
		if Thread.respond_to?(:each_caller_location)
			def each_caller_location(&block)
				Thread.each_caller_location(&block)
			end
		else
			def each_caller_location(&block)
				caller_locations(1).each(&block)
			end
		end
		
		def append_unique_key(key, unique = @unique)
			if @parent
				@parent.append_unique_key(key)
			else
				key << @path
			end
			
			if unique == true
				# No key is needed because this identity is unique.
			else
				if unique
					key << unique
				elsif @line
					key << @line
				end
			end
		end
	end
end
