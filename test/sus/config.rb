# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

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
end
