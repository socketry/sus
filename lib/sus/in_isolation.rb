# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require_relative 'let'

module Sus
	module Context
		def in_isolation(&block)
			let(:sandbox) do
				Module.new(&block)
			end
		end
	end
	
	class Base
		def in_isolation(&block)
			sandbox.instance_exec(&block)
		end
	end
end
