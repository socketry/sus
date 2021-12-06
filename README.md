# Sus(picious) \[working name\]

An opinionated test framework designed with several goals:

  - As fast as possible, aiming for \~10,000 assertions per second per core.
  - Isolated tests which parallelise easily (including `class` definitions).
  - Native support for balanced (work-stealing) multi-core execution.
  - Incredible test output with detailed failure logging (including nested assertions and predicates).

Non-features:

  - Flexibility at the expense of performance.
  - Backwards compatibility.

[![Development Status](https://github.com/ioquatix/sus/workflows/Development/badge.svg)](https://github.com/ioquatix/sus/actions?workflow=Development)

## Ideas

I've been thinking about how this should grow long term. I see a separation between "defining tests" and "running tests". I think this gem should be split across those responsibilities. By doing so, defining tests remains relatively static, but can be extended independently of execution model. And execution models which include parallelism, code coverage, multi-server, etc can be implemented effectively.

The key point is that we need a well defined interface between defining tests and running tests. This interface is provided by the test registry, which can load test files. The test registry provides a way to enumerate all tests where each test has an identity that uniquely identifies it.

### Sequential vs Parallel

`sus` has both sequential and multi-threaded (`sus-parallel`) execution models for tests. Parallel execution is potentially much faster. This is an experimental feature.

![Sequential vs Parallel](https://user-images.githubusercontent.com/30030/144770080-092cf07b-b121-4754-96e0-8ff1d8ea0695.mov)

## Installation

``` shell
bundle add sus
```

## Usage

Check `test` directory for examples.

## Contributing

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

## License

Released under the MIT license.

Copyright, 2021, by [Samuel G. D. Williams](https://www.codeotaku.com).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
