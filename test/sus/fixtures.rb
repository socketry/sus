# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Sus::Fixtures::TestFixture
end

describe Sus::Fixtures do
	include TestFixture
	
	it "should haven included the test fixture" do
		expect(self.class.ancestors).to be(:include?, Sus::Fixtures::TestFixture)
	end
end
