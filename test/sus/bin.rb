# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "open3"
require "rbconfig"

describe "bin/sus" do
	def run_sus(*arguments)
		Open3.capture3(
			{
				"RUBYOPT" => ENV["RUBYOPT"],
			},
			RbConfig.ruby,
			"bin/sus",
			*arguments,
			chdir: File.expand_path("../..", __dir__)
		)
	end
	
	it "can run passing tests quietly" do
		output, error, status = run_sus("fixtures/sus/bin/passing.rb")
		
		expect(status).to be(:success?)
		expect(output).to be == ""
	end
	
	it "can run passing tests verbosely" do
		output, error, status = run_sus("--verbose", "fixtures/sus/bin/passing.rb")
		
		expect(status).to be(:success?)
		expect(output + error).to be(:include?, "1 passed")
	end
	
	it "exits unsuccessfully when tests fail" do
		output, error, status = run_sus("fixtures/sus/bin/failing.rb")
		
		expect(status).not.to be(:success?)
		expect(output).to be == ""
	end
end
