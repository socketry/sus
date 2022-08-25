# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

describe Sus::VERSION do
	it "has a major.minor.patch version" do
		expect(subject).to be =~ /\d+\.\d+\.\d+/
	end
end
