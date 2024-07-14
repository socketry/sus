# Sus(picious)

An opinionated test framework designed with several goals:

  - As fast as possible, aiming for \~10,000 assertions per second per core.
  - Isolated tests which parallelise easily (including `class` definitions).
  - Native support for balanced (work-stealing) multi-core execution.
  - Incredible test output with detailed failure logging (including nested assertions and predicates).

Non-features:

  - Flexibility at the expense of performance.
  - Backwards compatibility.

[![Development Status](https://github.com/ioquatix/sus/workflows/Test/badge.svg)](https://github.com/ioquatix/sus/actions?workflow=Test)

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

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
