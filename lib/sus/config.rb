# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require_relative "clock"
require_relative "registry"

module Sus
	class Config
		PATH = "config/sus.rb"
		
		def self.path(root)
			path = ::File.join(root, PATH)
			
			if ::File.exist?(path)
				return path
			end
		end
		
		def self.load(root: Dir.pwd, arguments: ARGV)
			derived = Class.new(self)
			
			if path = self.path(root)
				config = Module.new
				config.module_eval(::File.read(path), path)
				derived.prepend(config)
			end
			
			options = {
				verbose: !!arguments.delete("--verbose")
			}
			
			return derived.new(root, arguments, **options)
		end
		
		def initialize(root, paths, verbose: false)
			@root = root
			@paths = paths
			@verbose = verbose
			
			@clock = Clock.new
			
			self.add_default_load_paths
		end
		
		def add_load_path(path)
			path = ::File.expand_path(path, @root)
			
			if ::File.directory?(path)
				$LOAD_PATH.unshift(path)
			end
		end
		
		def add_default_load_paths
			add_load_path("lib")
			add_load_path("fixtures")
		end
		
		attr :root
		attr :paths
		
		def verbose?
			@verbose
		end
		
		def partial?
			@paths.any?
		end
		
		def output
			@output ||= Sus::Output.default
		end
		
		DEFAULT_TEST_PATTERN = "test/**/*.rb"
		
		def test_paths
			return Dir.glob(DEFAULT_TEST_PATTERN, base: @root)
		end
		
		def make_registry
			Sus::Registry.new(root: @root)
		end
		
		def load_registry(paths = @paths)
			registry = make_registry
			
			if paths&.any?
				registry = Sus::Filter.new(registry)
				paths.each do |path|
					registry.load(path)
				end
			else
				test_paths.each do |path|
					registry.load(path)
				end
			end
			
			return registry
		end
		
		def registry
			@registry ||= self.load_registry
		end
		
		def prepare_warnings!
			Warning[:deprecated] = true
		end
		
		def before_tests(assertions, output: self.output)
			@clock.reset!
			@clock.start!
			
			prepare_warnings!
		end
		
		def after_tests(assertions, output: self.output)
			@clock.stop!
			
			self.print_summary(output, assertions)
		end
		
		protected
		
		def print_summary(output, assertions)
			assertions.print(output)
			output.puts
			
			print_finished_statistics(output, assertions)
			
			if !partial? and assertions.passed?
				print_test_feedback(output, assertions)
			end
			
			print_slow_tests(output, assertions)
			print_failed_assertions(output, assertions)
		end
		
		def print_finished_statistics(output, assertions)
			duration = @clock.duration
			rate = assertions.count / duration
			
			output.puts "🏁 Finished in ", @clock, "; #{rate.round(3)} assertions per second."
		end
		
		def print_test_feedback(output, assertions)
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
		
		def print_slow_tests(output, assertions, threshold = 0.1)
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
		
		def print_assertions(output, title, assertions)
			if assertions.any?
				output.puts
				output.puts title
				
				assertions.each do |assertion|
					output.append(assertion.output)
				end
			end
		end
		
		def print_failed_assertions(output, assertions)
			print_assertions(output, "🤔 Failed assertions:", assertions.failed)
			print_assertions(output, "🔥 Errored assertions:", assertions.errored)
		end
	end
end
