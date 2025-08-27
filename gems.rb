# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	gem "bake-releases"
	
	gem "agent-context"
	
	gem "utopia-project"
end

group :test do
	gem "covered"
	gem "decode"
	
	gem "rubocop"
	gem "rubocop-socketry"
	
	gem "bake-test"
	gem "bake-test-external"
end
