# frozen_string_literal: true

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
