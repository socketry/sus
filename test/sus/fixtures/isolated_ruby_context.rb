# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus/fixtures/isolated_ruby_context"
require "sus/fixtures/temporary_directory_context"

describe Sus::Fixtures::IsolatedRubyContext do
	include Sus::Fixtures::IsolatedRubyContext
	include Sus::Fixtures::TemporaryDirectoryContext
	
	it "preserves Ruby values and hash key types" do
		expect(isolated_ruby('{items: [1, 2.5, :three, true, false, nil], "range" => (1...5), pattern: /example/i}')).to be == {items: [1, 2.5, :three, true, false, nil], "range" => (1...5), pattern: /example/i}
		expect(isolated_ruby("nil")).to be_nil
	end
	
	it "preserves binary strings" do
		value = isolated_ruby('"\x00\xFF\r\n".b')
		expect(value).to be == "\x00\xFF\r\n".b
		expect(value.encoding).to be == Encoding::BINARY
	end
	
	it "preserves shared and cyclic references" do
		first, second = isolated_ruby("value = []; value << value; [value, value]")
		expect(first).to be(:equal?, second)
		expect(first.first).to be(:equal?, first)
	end
	
	it "keeps printed output separate from the result" do
		expect(isolated_ruby('puts "stdout"; warn "stderr"; {value: 42}')).to be == {value: 42}
	end
	
	it "inherits stderr" do
		expect(isolated_ruby("[STDERR.stat.dev, STDERR.stat.ino]")).to be == [STDERR.stat.dev, STDERR.stat.ino]
	end
	
	it "handles source and results larger than pipe buffers" do
		value = "x" * 1_048_576
		expect(isolated_ruby(value.inspect)).to be == value
	end
	
	it "runs in the requested directory without changing the caller's directory" do
		previous = Dir.pwd
		File.write(File.join(root, "value.rb"), "ISOLATED_VALUE = 42\n")
		result = isolated_ruby('require_relative "value"; {value: ISOLATED_VALUE, directory: Dir.pwd}', chdir: root)
		expect(result).to be == {value: 42, directory: File.realpath(root)}
		expect(Dir.pwd).to be == previous
		expect(Object).not.to be(:const_defined?, :ISOLATED_VALUE)
	end
	
	it "starts each evaluation with fresh Ruby state" do
		isolated_ruby("ISOLATED_VALUE = 42")
		expect(isolated_ruby("defined?(ISOLATED_VALUE)")).to be_nil
		expect(isolated_ruby("Process.pid")).not.to be == Process.pid
		expect(isolated_ruby("RUBY_VERSION")).to be == RUBY_VERSION
	end
	
	it "overrides the child environment without changing the caller's environment" do
		previous = ENV["SUS_ISOLATED_VALUE"]
		expect(isolated_ruby('ENV.fetch("SUS_ISOLATED_VALUE")', env: {"SUS_ISOLATED_VALUE" => "child"})).to be == "child"
		expect(isolated_ruby('ENV["SUS_ISOLATED_VALUE"]', env: {"SUS_ISOLATED_VALUE" => nil})).to be_nil
		expect(ENV["SUS_ISOLATED_VALUE"]).to be == previous
		expect(isolated_ruby('ENV["RUBYOPT"]')).to be == ENV["RUBYOPT"]
	end
	
	it "inherits RUBYOPT preload hooks in nested evaluations" do
		preload = File.join(root, "coverage_hook.rb")
		File.write(preload, "ISOLATED_COVERAGE_HOOK = true\n")
		fixture = File.expand_path("../../../lib/sus/fixtures/isolated_ruby_context", __dir__)
		result = isolated_ruby(<<~RUBY, env: {"RUBYOPT" => "-r#{preload}", "BUNDLER_SETUP" => nil})
			require #{fixture.inspect}
			Object.new.extend(Sus::Fixtures::IsolatedRubyContext).isolated_ruby("ISOLATED_COVERAGE_HOOK")
		RUBY
		expect(result).to be == true
	end
	
	it "allows callers to opt out of inherited startup hooks" do
		expect(isolated_ruby("defined?(Bundler)", env: {"RUBYOPT" => nil, "BUNDLER_SETUP" => nil})).to be_nil
	end
	
	it "loads explicitly requested features" do
		path = File.join(root, "value.rb")
		File.write(path, "puts \"loading feature\"; ISOLATED_VALUE = 42\n")
		expect(isolated_ruby("ISOLATED_VALUE", requires: [path])).to be == 42
	end
	
	it "allows source to use ordinary local variable names" do
		expect(isolated_ruby('output = "result"; result = {value: output}; result')).to be == {value: "result"}
	end
	
	it "re-raises exceptions with their original message and backtrace" do
		begin
			isolated_ruby('raise ArgumentError, "Broken evaluation"')
		rescue ArgumentError => error
			expect(error.message).to be == "Broken evaluation"
			expect(error.backtrace.first).to be =~ /\(isolated ruby\):1:/
		else
			fail "Expected the original exception"
		end
	end
	
	it "can return an exception as a value" do
		result = isolated_ruby('ArgumentError.new("A value")')
		expect(result).to be_a(ArgumentError)
		expect(result.message).to be == "A value"
	end
	
	it "re-raises syntax errors" do
		expect{isolated_ruby("def")}.to raise_exception(SyntaxError)
	end
	
	it "re-raises feature loading errors after accepting all source" do
		expect do
			isolated_ruby("nil\n" * 262_144, requires: [File.join(root, "missing.rb")])
		end.to raise_exception(LoadError)
	end
	
	it "reports serialization failures" do
		expect do
			isolated_ruby('["x" * 1_048_576, proc {}]')
		end.to raise_exception(TypeError, message: be =~ /Proc/)
	end
	
	it "reports process failure when an exception cannot be serialized" do
		expect do
			isolated_ruby(<<~RUBY)
				error = RuntimeError.new("Cannot serialize")
				error.instance_variable_set(:@callback, proc {})
				raise error
			RUBY
		end.to raise_exception(Sus::Fixtures::IsolatedRubyContext::Error)
	end
	
	it "reports startup failures before accepting all source" do
		preload = File.join(root, "failure.rb")
		File.write(preload, "exit 7\n")
		begin
			isolated_ruby(("x" * 1_048_576).inspect, env: {"RUBYOPT" => "-r#{preload}", "BUNDLER_SETUP" => nil})
		rescue Sus::Fixtures::IsolatedRubyContext::Error => error
			expect(error.status.exitstatus).to be == 7
		else
			fail "Expected a startup failure"
		end
	end
	
	it "returns nil for successful exits without a result" do
		expect(isolated_ruby("exit(0)")).to be_nil
	end
	
	it "reports unsuccessful exits without a result" do
		expect{isolated_ruby("exit(1)")}.to raise_exception(Sus::Fixtures::IsolatedRubyContext::Error)
	end
	
	it "supports concurrent evaluations in different directories" do
		previous = Dir.pwd
		paths = [File.join(root, "first"), File.join(root, "second")]
		paths.each{|path| Dir.mkdir(path)}
		threads = paths.map do |path|
			Thread.new{isolated_ruby("Dir.pwd", chdir: path)}
		end
		expect(threads.map(&:value)).to be == paths.map{|path| File.realpath(path)}
		expect(Dir.pwd).to be == previous
	ensure
		threads&.each(&:join)
	end
end
