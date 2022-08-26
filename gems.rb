# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

source "https://rubygems.org"

gemspec

gem "covered", "~> 0.16"

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
	
	gem "utopia-project"
end

group :test do
	gem "bake-test"
	gem "bake-test-external"
end
