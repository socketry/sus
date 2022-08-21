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

require_relative 'clock'

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
			@clock = Clock.new
			
			self.setup_load_paths
		end
		
		def add_load_path(path)
			path = File.expand_path(path, @root)
			
			if File.directory?(path)
				$LOAD_PATH.unshift(path)
			end
		end
		
		def setup_load_paths
			add_load_path("lib")
			add_load_path("fixtures")
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
			@clock.start!
		end
		
		def after_tests(assertions)
			@clock.stop!
			
			output = self.output
			
			assertions.print(output)
			output.puts

			print_finished_statistics(assertions)

			if !partial? and assertions.passed?
				print_test_feedback(assertions)
			end
						
			print_slow_tests(assertions)
			print_failed_assertions(assertions)
		end
		
		protected
		
		def partial?
			@paths.any?
		end
		
		def print_finished_statistics(assertions)
			duration = @clock.duration
			rate = assertions.count / duration
			
			output.puts "🏁 Finished in ", @clock, "; #{rate.round(3)} assertions per second."
		end
		
		def print_test_feedback(assertions)
			duration = @clock.duration
			rate = assertions.count / duration
			
			total = assertions.total
			count = assertions.count
			
			if total < 10 or count < 10
				output.puts "😭 You should write more tests and assertions!"
				
				# Statistics will be less meaningful with such a small amount of data, so give up:
				return
			end
			
			# Check whether there is at least, on average, one assertion (or more) per test:
			assertions_per_test = assertions.count / assertions.total
			if assertions_per_test < 1.0
				output.puts "😩 Your tests don't have enough assertions (#{assertions_per_test.round(1)} < 1.0)!"
			end
			
			# Give some feedback about the number of tests:
			if total < 20
				output.puts "🥲 You should write more tests (#{total}/20)!"
			elsif total < 50
				output.puts "🙂 Your test suite is starting to shape up, keep on at it (#{total}/50)!"
			elsif total < 100
				output.puts "😀 Your test suite is maturing, keep on at it (#{total}/100)!"
			else
				output.puts "🤩 Your test suite is amazing!"
			end
			
			# Give some feedback about the performance of the tests:
			if rate < 10.0
				output.puts "💔 Ouch! Your test suite performance is painful (#{rate.round(1)} < 10)!"
			elsif rate < 100.0
				output.puts "💩 Oops! Your test suite performance could be better (#{rate.round(1)} < 100)!"
			elsif rate < 1_000.0
				output.puts "💪 Good job! Your test suite has good performance (#{rate.round(1)} < 1000)!"
			elsif rate < 10_000.0
				output.puts "🎉 Great job! Your test suite has excellent performance (#{rate.round(1)} < 10000)!"
			else
				output.puts "🔥 Wow! Your test suite has outstanding performance (#{rate.round(1)} >= 10000.0)!"
			end
		end
		
		def print_slow_tests(assertions, threshold = 0.1)
			slowest_tests = assertions.passed.select{|test| test.clock > threshold}.sort_by(&:clock).reverse!
			
			if slowest_tests.empty?
				output.puts "🐇 No slow tests found! Well done!"
			else
				output.puts "🐢 Slow tests:"
			
				slowest_tests.each do |test|
					output.puts "\t", :variable, test.clock, :reset, ": ", test.target
				end
			end
		end
		
		def print_failed_assertions(assertions)
			if assertions.failed.any?
				output.puts
				
				assertions.failed.each do |failure|
					output.append(failure.output)
				end
			end
		end
	end
end
