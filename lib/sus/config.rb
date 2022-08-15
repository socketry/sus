# frozen_string_literal: true

# Copyright, 2022, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Sus
	class Config
		PATH = "config/sus.rb"
		
		def self.path(root)
			path = ::File.join(root, PATH)
			
			if ::File.exist?(path)
				return path
			end
		end
		
		def self.load(root: Dir.pwd, argv: ARGV)
			derived = Class.new(self)
			
			if path = self.path(root)
				config = Module.new
				config.module_eval(::File.read(path), path)
				derived.prepend(config)
			end
			
			return derived.new(root, argv)
		end
		
		def initialize(root, paths)
			@root = root
			@paths = paths
		end
		
		def output
			@output ||= Sus::Output.default
		end
		
		DEFAULT_TEST_PATTERN = "test/**/*.rb"
		
		def test_paths
			return Dir.glob(DEFAULT_TEST_PATTERN, base: @root)
		end
		
		def prepare(registry)
			if @paths&.any?
				@paths.each do |path|
					registry.load(path)
				end
			else
				test_paths.each do |path|
					registry.load(path)
				end
			end
		end
		
		def before_tests(assertions)
		end
		
		def after_tests(assertions)
			output = self.output
			
			assertions.print(output)
			output.puts
			
			if assertions.failed.any?
				output.puts
				
				assertions.failed.each do |failure|
					output.append(failure.output)
				end
			end
		end
	end
end
