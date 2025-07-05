# Releases

## v0.33.0

  - Add support for `agent-context` gem.

### `receive` now supports blocks and `and_raise`.

The `receive` predicate has been enhanced to support blocks and the `and_raise` method, allowing for more flexible mocking of method calls.

``` ruby
# `receive` with a block:
expect(interface).to receive(:implementation) {10}

# `and_return` with a block:
expect(interface).to receive(:implementation).and_return{FakeImplementation.new}

# `and_raise` for error handling:
expect(interface).to receive(:implementation).and_raise(StandardError, "An error occurred")
```

## v0.32.0

  - `Sus::Config` now has a `prepare_warnings!` hook which enables deprecated warnings by default. This is generally considered good behaviour for a test framework.
