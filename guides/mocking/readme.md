# Mocking

This guide explains how to use mocking in sus to isolate dependencies and verify interactions in your tests.

## Overview

When testing code that depends on external services, slow operations, or complex objects, you need a way to control those dependencies without actually invoking them. Mocking allows you to replace method implementations or set expectations on method calls, making your tests faster, more reliable, and easier to maintain.

Use mocking when you need:
- **Isolation**: Test your code without depending on external services (databases, APIs, file systems)
- **Performance**: Avoid slow operations during testing
- **Control**: Simulate error conditions or edge cases that are hard to reproduce
- **Verification**: Ensure your code calls methods with the correct arguments

Sus provides two types of mocking: `receive` for method call expectations and `mock` for replacing method implementations. The `receive` matcher is a subset of full mocking and is used to set expectations on method calls, while `mock` can be used to replace method implementations or set up more complex behavior.

**Important**: Mocking non-local objects permanently changes the object's ancestors, so it should be used with care. For local objects, you can use `let` to define the object and then mock it.

Sus does not support the concept of test doubles, but you can use `receive` and `mock` to achieve similar functionality.

## Method Call Expectations

The `receive(:method)` expectation is used to set up an expectation that a method will be called on an object. You can also specify arguments and return values. However, `receive` is not sequenced, meaning it does not enforce the order of method calls. If you need to enforce the order, use `mock` instead.

### Basic Usage

Verify that a method is called:

```ruby
describe PaymentProcessor do
	let(:payment_processor) {subject.new}
	let(:logger) {Object.new}
	
	it "logs payment attempts" do
		expect(logger).to receive(:info)
		
		payment_processor.process_payment(amount: 100, logger: logger)
	end
end
```

### With Arguments

Verify method calls with specific arguments:

```ruby
describe EmailService do
	let(:email_service) {subject.new}
	let(:smtp_client) {Object.new}
	
	it "sends emails with correct recipient and subject" do
		expect(smtp_client).to receive(:send).with("user@example.com", "Welcome!")
		
		email_service.send_welcome_email("user@example.com", smtp_client)
	end
end
```

You can also use more flexible argument matching:
- `.with_arguments(be == [arg1, arg2])` for positional arguments
- `.with_options(be == {option1: value1})` for keyword arguments
- `.with_block` to verify a block is passed

### Returning Values

Set up return values for mocked methods:

```ruby
describe UserRepository do
	let(:repository) {subject.new}
	let(:database) {Object.new}
	
	it "retrieves user by ID" do
		expected_user = {id: 1, name: "Alice"}
		expect(database).to receive(:find_user).with(1).and_return(expected_user)
		
		user = repository.find(1, database)
		expect(user).to be == expected_user
	end
end
```

### Raising Exceptions

Simulate error conditions:

```ruby
describe FileUploader do
	let(:uploader) {subject.new}
	let(:storage_service) {Object.new}
	
	it "handles storage failures gracefully" do
		expect(storage_service).to receive(:upload).and_raise(StandardError, "Storage unavailable")
		
		expect{uploader.upload_file("data.txt", storage_service)}.to raise_exception(StandardError, message: "Storage unavailable")
	end
end
```

### Multiple Calls

Verify methods are called multiple times:

```ruby
describe CacheWarmer do
	let(:warmer) {subject.new}
	let(:cache) {Object.new}
	
	it "warms multiple cache entries" do
		expect(cache).to receive(:set).twice.and_return(true)
		
		warmer.warm(["key1", "key2"], cache)
	end
end
```

You can also use `.with_call_count(be == 2)` for more flexible call count expectations.

## Mock Objects

Mock objects are used to replace method implementations or set up complex behavior. They can be used to intercept method calls, modify arguments, and control the flow of execution. They are thread-local, meaning they only affect the current thread, therefore are not suitable for use in tests that have multiple threads.

### Replacing Method Implementations

Replace methods to return controlled values:

```ruby
describe ApiClient do
	let(:http_client) {Object.new}
	let(:client) {ApiClient.new(http_client)}
	let(:users) {["Alice", "Bob"]}
	
	it "fetches users from API" do
		mock(http_client) do |mock|
			mock.replace(:get) do |url, headers: {}|
				expect(url).to be == "/api/users"
				expect(headers).to be == {"accept" => "application/json"}
				users.to_json
			end
		end
		
		expect(client.fetch_users).to be == users
	end
end
```

### Advanced Mocking Patterns

You can also use:
- `mock.before {|...| ...}` to execute code before the original method
- `mock.after {|...| ...}` to execute code after the original method
- `mock.wrap(:method) {|original, ...| original.call(...)}` to wrap the original method

## Best Practices

1. **Prefer real objects**: Use mocks only when necessary (external services, slow operations, error conditions)
2. **Use dependency injection**: Make dependencies explicit so they can be easily mocked
3. **Mock at boundaries**: Mock external services, not internal implementation details
4. **Keep mocks simple**: Complex mock setups indicate the code might need refactoring

## Common Pitfalls

1. **Over-mocking**: Mocking too much makes tests brittle and less valuable
2. **Thread safety**: Mock objects are thread-local, don't use them in multi-threaded tests
3. **Permanent changes**: Mocking non-local objects permanently changes their ancestors - use `let` for local objects instead
