# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Sus
	# Provides a way to filter the registry according to the suffix on loaded paths.
	#
	# A test has an identity, e.g. the file and line number on which it's defined.
	#
	# A filter takes an identity, decomposes it into a file and suffix, loads the file, and registers the filter suffix.
	#
	# When the filter is used to enumerate the registry, it will only return the tests that match the suffix.
	class Filter
		# Represents an index of contexts by their identity keys.
		class Index
			# Initialize a new Index.
			def initialize
				@contexts = {}
			end
			
			# @attribute [Hash] A hash mapping identity keys to contexts.
			attr :contexts
			
			# Add all children from a parent context to the index.
			# @parameter parent [Object] The parent context.
			def add(parent)
				parent.children&.each do |identity, child|
					insert(identity, child)
					add(child)
				end
			end
			
			# Insert a context into the index.
			# @parameter identity [Identity] The identity of the context.
			# @parameter context [Object] The context to index.
			# @raises [KeyError] If a context with the same key already exists.
			def insert(identity, context)
				key = identity.key
				
				if existing_context = @contexts[key]
					raise KeyError, "Assigning context to existing key: #{key.inspect}!"
				else
					@contexts[key] = context
				end
			end
			
			# Look up a context by its key.
			# @parameter key [String] The identity key.
			# @returns [Object, nil] The context if found.
			def [] key
				@contexts[key]
			end
		end
		
		# Initialize a new Filter.
		# @parameter registry [Registry] The registry to filter.
		def initialize(registry = Registry.new)
			@registry = registry
			@index = nil
			@keys = Array.new
		end
		
		# Load a target path, optionally with a filter suffix.
		# @parameter target [String] The target path, optionally with a ":suffix" filter.
		def load(target)
			path, filter = target.split(":", 2)
			
			@registry.load(path)
			
			if filter
				@keys << target
			end
		end
		
		# Iterate over filtered test cases.
		# @yields {|test| ...} Each test case that matches the filter.
		def each(&block)
			if @keys.any?
				@index = Index.new
				@index.add(@registry)
				
				@keys.each do |key|
					if target = @index[key]
						yield target
					end
				end
			else
				@registry.each(&block)
			end
		end
		
		# Execute filtered tests.
		# @parameter assertions [Assertions] Optional assertions instance to use.
		# @returns [Assertions] The assertions instance with results.
		def call(assertions = Assertions.default)
			if @keys.any?
				@index = Index.new
				@index.add(@registry)
				
				@keys.each do |key|
					@index[key]&.call(assertions)
				end
			else
				@registry.call(assertions)
			end
			
			return assertions
		end
	end
end
