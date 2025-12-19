# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	# Represents a unique identity for a test or context, used for identification and location tracking.
	class Identity
		# Create an identity for a file.
		# @parameter parent [Identity, nil] The parent identity.
		# @parameter path [String] The file path.
		# @parameter name [String] The name (defaults to path).
		# @parameter options [Hash] Additional options.
		# @returns [Identity] A new Identity instance.
		def self.file(parent, path, name = path, **options)
			self.new(path, name, nil, nil, **options)
		end
		
		# Create a nested identity.
		# @parameter parent [Identity, nil] The parent identity.
		# @parameter name [String] The name of this identity.
		# @parameter location [Thread::Backtrace::Location, nil] Optional location (defaults to caller location).
		# @parameter options [Hash] Additional options.
		# @returns [Identity] A new Identity instance.
		def self.nested(parent, name, location = nil, **options)
			location ||= caller_locations(3...4).first
			
			self.new(location.path, name, location.lineno, parent, **options)
		end
		
		# Create an identity for the current location.
		# @returns [Identity] A new Identity instance for the current caller location.
		def self.current
			self.nested(nil, nil, caller_locations(1...2).first)
		end
		
		# Initialize a new Identity.
		# @parameter path [String] The file path.
		# @parameter name [String, nil] Optional name.
		# @parameter line [Integer, nil] Optional line number.
		# @parameter parent [Identity, nil] Optional parent identity.
		# @parameter unique [Boolean, Symbol] Whether this identity is unique or needs a unique key/line number suffix.
		def initialize(path, name = nil, line = nil, parent = nil, unique: true)
			@path = path
			@name = name
			@line = line
			@parent = parent
			@unique = unique
			
			@key = nil
		end
		
		# Create a new identity with a different line number.
		# @parameter line [Integer] The line number.
		# @returns [Identity] A new Identity instance.
		def with_line(line)
			self.class.new(@path, @name, line, @parent, unique: @unique)
		end
		
		# @attribute [String] The file path.
		attr :path
		
		# @attribute [String, nil] The name.
		attr :name
		
		# @attribute [Integer, nil] The line number.
		attr :line
		
		# @attribute [Identity, nil] The parent identity.
		attr :parent
		
		# @attribute [Boolean, Symbol] Whether this identity is unique.
		attr :unique
		
		# @returns [String] A string representation of this identity (the key).
		def to_s
			self.key
		end
		
		# @returns [Hash] A hash containing the path and line number.
		def to_location
			{
				path: ::File.expand_path(@path),
				line: @line,
			}
		end
		
		# @returns [String] An inspect representation of this identity.
		def inspect
			"\#<#{self.class} #{self.to_s}>"
		end
		
		# Check if this identity matches another.
		# @parameter other [Identity] The identity to match against.
		# @returns [Boolean] Whether the identities match.
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
		
		# Iterate over this identity and all its parents.
		# @yields {|identity| ...} Each identity in the chain.
		def each(&block)
			@parent&.each(&block)
			
			yield self
		end
		
		# @returns [String] A unique key for this identity.
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
		# @parameter locations [Array(Thread::Backtrace::Location), nil] Optional locations to search (defaults to caller locations).
		# @returns [Identity] A new identity with updated line number if a match is found, otherwise returns self.
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
