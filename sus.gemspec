# frozen_string_literal: true

require_relative "lib/sus/version"

Gem::Specification.new do |spec|
	spec.name = "sus"
	spec.version = Sus::VERSION
	
	spec.summary = "A fast and scalable test runner."
	spec.authors = ["Samuel Williams", "Brad Schrag"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/sus"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/sus/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/socketry/sus.git",
	}
	
	spec.files = Dir.glob(["{bin,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["sus", "sus-parallel", "sus-tree", "sus-host"]
	
	spec.required_ruby_version = ">= 3.1"
end
