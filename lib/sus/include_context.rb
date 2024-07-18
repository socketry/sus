# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require_relative 'context'

module Sus
	module IncludeContext
		module Helpers
			def prepend(*arguments, &block)
				arguments.each do |argument|
					if argument.class == Module
						super(argument)
					else
						argument.prepended(self)
					end
				end

				if block_given?
					wrapper = Module.new
					wrapper.instance_exec(&block)
					super(wrapper)
				end
			end
			
			def include(*arguments, &block)
				arguments.each do |argument|
					if argument.class == Module
						super(argument)
					else
						argument.included(self)
					end
				end
				
				if block_given?
					wrapper = Module.new
					wrapper.module_exec(&block)
					super(wrapper)
				end
			end
		end
	end
	
	module Context
		include IncludeContext::Helpers
		
		def include_context(shared, ...)
			shared.included(self, ...)
		end
	end
end
