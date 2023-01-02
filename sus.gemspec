# frozen_string_literal: true

require_relative "lib/sus/version"

Gem::Specification.new do |spec|
	spec.name = "sus"
	spec.version = Sus::VERSION
	
	spec.summary = "A fast and scalable test runner."
	spec.authors = ["Samuel Williams", "Brad Schrag"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/ioquatix/sus"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob(['{bin,lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["sus", "sus-parallel"]
	
	spec.required_ruby_version = ">= 2.7.0"
	
	spec.add_development_dependency "bake-test", "~> 0.1"
	spec.add_development_dependency "bake-test-external", "~> 0.1"
	spec.add_development_dependency "covered", "~> 0.18"
end
