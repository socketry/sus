# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/output/summary"
require "sus/output/null"
require "sus/assertions"
require "sus/clock"

require "json"
require "stringio"

describe Sus::Output::Summary do
	let(:io) {StringIO.new}
	let(:summary) {subject.new(io)}
	
	def document
		JSON.parse(io.string, symbolize_names: true)
	end
	
	with "a failing run" do
		it "emits a JSON document describing the failure" do
			identity = Sus::Identity.new(__FILE__, "example", 42)
			assertions = Sus::Assertions.new(identity: identity, output: Sus::Output::Null.new)
			
			assertions.nested("example", distinct: true) do |nested|
				nested.assert(false, "deliberate failure")
			end
			
			summary.summary(assertions, clock: Sus::Clock.new)
			
			expect(document[:success]).to be == false
			expect(document[:failed]).to be == 1
			expect(document[:failures].first[:detail]).to be(:include?, "deliberate failure")
			expect(document[:failures].first[:location][:line]).to be == 42
		end
	end
	
	with "a passing run" do
		it "reports success with no failures" do
			assertions = Sus::Assertions.new(output: Sus::Output::Null.new)
			
			assertions.nested("example", distinct: true) do |nested|
				nested.assert(true, "ok")
			end
			
			summary.summary(assertions, clock: Sus::Clock.new)
			
			expect(document[:success]).to be == true
			expect(document[:failed]).to be == 0
			expect(document[:failures]).to be == []
		end
	end
end
