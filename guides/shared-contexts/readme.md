# Shared Test Behaviors and Fixtures

This guide explains how to use shared test contexts and fixtures in sus to reduce duplication and ensure consistent test behavior across your test suite.

## Overview

When you have common test behaviors that need to be applied to multiple test files or multiple implementations of the same interface, shared contexts allow you to define those behaviors once and reuse them. This reduces duplication, ensures consistency, and makes it easier to maintain your tests.

Use shared contexts when you need:
- **Code reuse**: Apply the same test behavior to multiple classes or modules
- **Consistency**: Ensure all implementations of an interface are tested the same way
- **Maintainability**: Update test behavior in one place rather than many
- **Parameterization**: Run the same tests with different inputs or configurations

Sus provides shared test contexts which can be used to define common behaviours or tests that can be reused across one or more test files.

When you have common test behaviors that you want to apply to multiple test files, add them to the `fixtures/` directory. When you have common test behaviors that you want to apply to multiple implementations of the same interface, within a single test file, you can define them as shared contexts within that file.

## Shared Fixtures

### Directory Structure

Shared fixtures are stored in the `fixtures/` directory, which mirrors your project structure:

```
my-gem/
├── lib/
│   ├── my_gem.rb
│   └── my_gem/
│       └── my_thing.rb
├── fixtures/
│   └── my_gem/
│       └── a_thing.rb               # Provides MyGem::AThing shared context
└── test/
    ├── my_gem.rb
    └── my_gem/
        └── my_thing.rb
```

The `fixtures/` directory is automatically added to the `$LOAD_PATH`, so you can require files from there without needing to specify the full path.

### Creating Shared Fixtures

Create shared behaviors in the `fixtures/` directory using `Sus::Shared`:

```ruby
# fixtures/my_gem/a_user.rb

require "sus/shared"

module MyGem
	AUser = Sus::Shared("a user") do |role|
		let(:user) do
			{
				name: "Test User",
				email: "test@example.com",
				role: role
			}
		end
		
		it "has a name" do
			expect(user[:name]).not.to be_nil
		end
		
		it "has a valid email" do
			expect(user[:email]).to be(:include?, "@")
		end
		
		it "has a role" do
			expect(user[:role]).to be_a(String)
		end
	end
end
```

### Using Shared Fixtures

Require and use shared fixtures in your test files:

```ruby
# test/my_gem/user_manager.rb
require "my_gem/a_user"

describe MyGem::UserManager do
	it_behaves_like MyGem::AUser, "manager"
	# or include_context MyGem::AUser, "manager"
end
```

### Multiple Shared Fixtures

You can create multiple shared fixtures for different scenarios:

```ruby
# fixtures/my_gem/users.rb
module MyGem
	module Users
		AStandardUser = Sus::Shared("a standard user") do
			let(:user) do
				{ name: "John Doe", role: "user", active: true }
			end
			
			it "is active" do
				expect(user[:active]).to be_truthy
			end
		end
		
		AnAdminUser = Sus::Shared("an admin user") do
			let(:user) do
				{ name: "Admin User", role: "admin", active: true }
			end
			
			it "has admin role" do
				expect(user[:role]).to be == "admin"
			end
		end
	end
end
```

Use specific shared fixtures:

```ruby
# test/my_gem/authorization.rb
require "my_gem/users"

describe MyGem::Authorization do
	with "standard user" do
		# If there are no arguments, you can use `include` directly:
		include MyGem::Users::AStandardUser
		
		it "denies admin access" do
			auth = subject.new
			expect(auth.can_admin?(user)).to be_falsey
		end
	end
	
	with "admin user" do
		include MyGem::Users::AnAdminUser
		
		it "allows admin access" do
			auth = subject.new
			expect(auth.can_admin?(user)).to be_truthy
		end
	end
end
```

### Modules

You can also define shared behaviors in modules and include them in your test files:

```ruby
# fixtures/my_gem/shared_behaviors.rb
module MyGem
	module SharedBehaviors
		def self.included(base)
			base.it "uses shared data" do
				expect(shared_data).to be == "some shared data"
			end
		end
		
		def shared_data
			"some shared data"
		end
	end
end
```

### Enumerating Tests

Some tests will be run multiple times with different arguments (for example, multiple database adapters). You can use `Sus::Shared` to define these tests and then enumerate them:

```ruby
# test/my_gem/database_adapter.rb

require "sus/shared"

ADatabaseAdapter = Sus::Shared("a database adapter") do |adapter|
	let(:database) {adapter.new}
	
	it "connects to the database" do
		expect(database.connect).to be_truthy
	end
	
	it "can execute queries" do
		expect(database.execute("SELECT 1")).to be == [[1]]
	end
end

# Enumerate the tests with different adapters
MyGem::DatabaseAdapters.each do |adapter|
	describe "with #{adapter}", unique: adapter.name do
		it_behaves_like ADatabaseAdapter, adapter
	end
end
```

Note the use of `unique: adapter.name` to ensure each test is uniquely identified, which is useful for reporting and debugging - otherwise the same test line number would be used for all iterations, which can make it hard to identify which specific test failed.

## Isolated Ruby

Use `Sus::Fixtures::IsolatedRubyContext` to evaluate Ruby in a fresh process and assert on its result. This is useful for code that relies on a working directory, environment variables, or constants which must be isolated from other tests.

```ruby
require "sus/fixtures/isolated_ruby_context"
require "sus/fixtures/temporary_directory_context"

describe "isolated evaluation" do
	include Sus::Fixtures::IsolatedRubyContext
	include Sus::Fixtures::TemporaryDirectoryContext
	
	it "reads files in the fixture directory" do
		File.write(File.join(root, "value.txt"), "example")
		result = isolated_ruby(<<~RUBY, chdir: root)
			{value: File.read("value.txt")}
		RUBY
		
		expect(result[:value]).to be == "example"
	end
end
```

The final expression is returned using `Marshal.dump` and `Marshal.load`, preserving Ruby types, hash keys, string encodings, and shared or cyclic references. The result must support Marshal serialization, and any custom classes it uses must also be loaded in the caller.

Exceptions raised while loading requested features, evaluating source, or serializing the result are marshaled back and re-raised in the caller with their original class, message, and backtrace. Custom exception classes must also be loaded in the caller. Returning an exception object as the final expression returns it as a value.

Printed output goes to the inherited stderr, keeping it separate from the result. An unsuccessful child that cannot return an exception raises `IsolatedRubyContext::Error`, which exposes its `status`; diagnostics appear directly on stderr. This includes startup failures, unsuccessful explicit exits, and exceptions that cannot be marshaled. A successful exit without a result, such as `exit(0)`, returns `nil`.

The fixture uses the current Ruby interpreter and defaults to the caller's working directory. `chdir:` changes only the child's directory, so evaluations can run concurrently. The child inherits the environment, including `RUBYOPT` so coverage and other startup hooks continue to run. `env:` supplies child environment overrides; a nil value removes a variable. For a clean startup without inherited Ruby or Bundler hooks, pass `env: {"RUBYOPT" => nil, "BUNDLER_SETUP" => nil}`.

Use `requires:` to load features before evaluating the source. To set up a particular bundle, use an absolute Gemfile path:

```ruby
result = isolated_ruby(
	'require "my_gem"; {version: MyGem::VERSION}',
	chdir: root,
	env: {"BUNDLE_GEMFILE" => File.expand_path("gems.rb")},
	requires: ["bundler/setup"]
)
```

The fixture accepts source code rather than a block; parent local variables and loaded Ruby state are not transferred to the child. It works independently of `TemporaryDirectoryContext`.

## Best Practices

1. **Organize by domain**: Group related shared contexts together in modules
2. **Keep contexts focused**: Each shared context should test one cohesive behavior
3. **Use parameters**: Make shared contexts flexible by accepting parameters
4. **Document intent**: Use clear names that explain what behavior is being tested

## Common Pitfalls

1. **Over-sharing**: Don't create shared contexts for behaviors that are only used once
2. **Tight coupling**: Avoid shared contexts that depend on too many specific implementation details
3. **Unclear names**: Use descriptive names that make it obvious what behavior is being tested
