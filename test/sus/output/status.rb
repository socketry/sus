# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require "sus/output/status"

describe Sus::Output::Status do
	let(:buffer) {StringIO.new}
	let(:output) {Sus::Output.for(buffer)}
	
	def before
		Sus::Output::Status.register(output)
	end
	
	it "has registered output formats" do
		expect(output.styles).to be(:include?, :free)
		expect(output.styles).to be(:include?, :busy)
	end
	
	let(:status) {subject.new}
	
	it "can print free status indicator" do
		status.print(output)
		expect(buffer.string).to be == "◌ \n"
	end
	
	it "can print busy status indicator" do
		status.update(:busy)
		status.print(output)
		expect(buffer.string).to be =~ /[◑◒◐◓] \n/
	end
end
