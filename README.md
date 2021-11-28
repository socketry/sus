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
