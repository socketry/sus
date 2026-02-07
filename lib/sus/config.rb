# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require_relative "clock"
require_relative "registry"

module Sus
	# Represents the configuration for running tests.
	class Config
		# The default path to the configuration file.
		PATH = "config/sus.rb"
		
		# Find the configuration file path for the given root directory.
		# @parameter root [String] The root directory to search in.
		# @returns [String | Nil] The path to the configuration file if it exists.
		def self.path(root)
			path = ::File.join(root, PATH)
			
			if ::File.exist?(path)
				return path
			end
		end
		
		# Load configuration from the given root directory.
		# @parameter root [String] The root directory to load configuration from.
		# @parameter arguments [Array] Command line arguments to parse.
		# @returns [Config] A new Config instance.
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
		
		# Initialize a new Config instance.
		# @parameter root [String] The root directory for the project.
		# @parameter paths [Array] Optional paths to specific test files.
		# @parameter verbose [Boolean] Whether to output verbose information.
		def initialize(root, paths, verbose: false)
			@root = root
			@paths = paths
			@verbose = verbose
			
			@clock = Clock.new
			
			self.add_default_load_paths
		end
		
		# Add a directory to the load path.
		# @parameter path [String] The path to add.
		def add_load_path(path)
			path = ::File.expand_path(path, @root)
			
			if ::File.directory?(path)
				$LOAD_PATH.unshift(path)
			end
		end
		
		# Add default load paths (lib and fixtures).
		def add_default_load_paths
			add_load_path("lib")
			add_load_path("fixtures")
		end
		
		# @attribute [String] The root directory for the project.
		attr :root
		
		# @attribute [Array] Optional paths to specific test files.
		attr :paths
		
		# @returns [Boolean] Whether verbose output is enabled.
		def verbose?
			@verbose
		end
		
		# @returns [Boolean] Whether only a partial set of tests is being run.
		def partial?
			@paths.any?
		end
		
		# @returns [Output] The output handler to use.
		def output
			@output ||= Sus::Output.default
		end
		
		# The default pattern for finding test files.
		DEFAULT_TEST_PATTERN = "test/**/*.rb"
		
		# @returns [Array(String)] Paths to all test files matching the default pattern.
		def test_paths
			return Dir.glob(DEFAULT_TEST_PATTERN, base: @root)
		end
		
		# Create a new registry instance.
		# @returns [Registry] A new Registry instance.
		def make_registry
			Sus::Registry.new(root: @root)
		end
		
		# Load the test registry, optionally filtering by paths.
		# @parameter paths [Array | Nil] Optional paths to filter tests by.
		# @returns [Registry, Filter] The loaded registry, possibly wrapped in a Filter.
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
		
		# @returns [Registry] The test registry, loading it if necessary.
		def registry
			@registry ||= self.load_registry
		end
		
		# Prepare Ruby warnings for deprecated features.
		def prepare_warnings!
			Warning[:deprecated] = true
		end
		
		# Called before tests are run.
		# @parameter assertions [Assertions] The assertions instance.
		# @parameter output [Output] The output handler.
		def before_tests(assertions, output: self.output)
			@clock.reset!
			@clock.start!
			
			prepare_warnings!
		end
		
		# Called after tests are run.
		# @parameter assertions [Assertions] The assertions instance.
		# @parameter output [Output] The output handler.
		def after_tests(assertions, output: self.output)
			@clock.stop!
			
			self.print_summary(output, assertions)
		end
		
		protected
		
		# Print a summary of test results.
		# @parameter output [Output] The output handler.
		# @parameter assertions [Assertions] The assertions instance.
		def print_summary(output, assertions)
			assertions.print(output)
			output.puts
			
			print_finished_statistics(output, assertions)
			
			unless assertions.count.zero?
				if !partial? and assertions.passed?
					print_test_feedback(output, assertions)
				end
				
				print_slow_tests(output, assertions)
			end
			
			print_failed_assertions(output, assertions)
		end
		
		# Print finished statistics.
		# @parameter output [Output] The output handler.
		# @parameter assertions [Assertions] The assertions instance.
		def print_finished_statistics(output, assertions)
			duration = @clock.duration
			
			if assertions.count.zero?
				output.puts "🏴 Finished in ", @clock, "."
			else
				rate = assertions.count / duration
				output.puts "🏁 Finished in ", @clock, "; #{rate.round(3)} assertions per second."
			end
		end
		
		# Print feedback about the test suite.
		# @parameter output [Output] The output handler.
		# @parameter assertions [Assertions] The assertions instance.
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
		
		# Print information about slow tests.
		# @parameter output [Output] The output handler.
		# @parameter assertions [Assertions] The assertions instance.
		# @parameter threshold [Float] The threshold in seconds for considering a test slow.
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
		
		# Print a list of assertions.
		# @parameter output [Output] The output handler.
		# @parameter title [String] The title to print.
		# @parameter assertions [Array] The assertions to print.
		def print_assertions(output, title, assertions)
			if assertions.any?
				output.puts
				output.puts title
				
				assertions.each do |assertion|
					output.append(assertion.output)
				end
			end
		end
		
		# Print failed and errored assertions.
		# @parameter output [Output] The output handler.
		# @parameter assertions [Assertions] The assertions instance.
		def print_failed_assertions(output, assertions)
			print_assertions(output, "🤔 Failed assertions:", assertions.failed)
			print_assertions(output, "🔥 Errored assertions:", assertions.errored)
		end
	end
end
