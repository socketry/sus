# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2026, by Samuel Williams.
# Copyright, 2026, by William T. Nelson.

require "fixtures"

class Target
	def print(output)
		output.write("target")
	end
end

describe Sus::Config do
	include Fixtures
	
	let(:root) {fixtures_path("sus/config/empty")}
	let(:config) {subject.load(root: root)}
	
	it "can load config from file" do
		expect(config).not.to be(:nil?)
	end
	
	with "summary output" do
		let(:io) {StringIO.new}
		let(:output) {Sus::Output::Text.new(io)}
		let(:assertions) {Sus::Assertions.new(output: Sus::Output.buffered)}
		
		with "errors and no assertions" do
			it "suppresses laudatory output but prints timing" do
				assertions.nested(Target.new, isolated: true) do |nested|
					nested.error!(RuntimeError.new("load error"))
				end
				
				config.before_tests(assertions, output: output)
				config.after_tests(assertions, output: output)
				
				expect(io.string).to be(:include?, "🏴 Finished in")
				expect(io.string).not.to be(:include?, "assertions per second")
				expect(io.string).not.to be(:include?, "No slow tests found")
				expect(io.string).to be(:include?, "Errored assertions")
			end
		end
		
		with "no assertions and no errors" do
			it "suppresses laudatory output but prints timing" do
				config.before_tests(assertions, output: output)
				config.after_tests(assertions, output: output)
				
				expect(io.string).to be(:include?, "🏴 Finished in")
				expect(io.string).not.to be(:include?, "assertions per second")
				expect(io.string).not.to be(:include?, "No slow tests found")
			end
		end
		
		with "passing assertions" do
			it "prints statistics and slow test output" do
				assertions.nested(Target.new, isolated: true, measure: true) do |nested|
					nested.assert(true)
				end
				
				config.before_tests(assertions, output: output)
				config.after_tests(assertions, output: output)
				
				expect(io.string).to be(:include?, "Finished in")
				expect(io.string).to be(:include?, "No slow tests found")
			end
		end
	end
	
	with "test feedback" do
		let(:io) {StringIO.new}
		let(:output) {Sus::Output::Text.new(io)}
		
		def print_test_feedback(count, total, duration)
			config.print_test_feedback(output, count: count, total: total, duration: duration)
			io.string
		end
		
		it "reports too few assertions and slow performance" do
			output = print_test_feedback(10, 15, 2.0)
			
			expect(output).to be(:include?, "don't have enough assertions")
			expect(output).to be(:include?, "write more tests")
			expect(output).to be(:include?, "performance is painful")
		end
		
		it "reports an early test suite and poor performance" do
			output = print_test_feedback(20, 20, 1.0)
			
			expect(output).to be(:include?, "starting to shape up")
			expect(output).to be(:include?, "could be better")
		end
		
		it "reports a maturing test suite and good performance" do
			output = print_test_feedback(60, 60, 0.1)
			
			expect(output).to be(:include?, "maturing")
			expect(output).to be(:include?, "good performance")
		end
		
		it "reports amazing test suite and excellent performance" do
			output = print_test_feedback(100, 100, 0.05)
			
			expect(output).to be(:include?, "amazing")
			expect(output).to be(:include?, "excellent performance")
		end
		
		it "reports outstanding performance" do
			output = print_test_feedback(10_000, 10_000, 1.0)
			
			expect(output).to be(:include?, "outstanding performance")
		end
	end
end
