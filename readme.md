# Sus

An opinionated test framework designed with several goals:

  - As fast as possible, aiming for \~10,000 assertions per second per core.
  - Isolated tests which parallelise easily (including `class` definitions).
  - Native support for balanced (work-stealing) multi-core execution.
  - Incredible test output with detailed failure logging (including nested assertions and predicates).

Non-features:

  - Flexibility at the expense of performance.
  - Backwards compatibility (for now).

[![Development Status](https://github.com/socketry/sus/workflows/Test/badge.svg)](https://github.com/socketry/sus/actions?workflow=Test)

## Usage

Please see the [project documentation](https://socketry.github.io/sus/) for more details.

  - [Getting Started](https://socketry.github.io/sus/guides/getting-started/index) - This guide explains how to use the `sus` gem to write tests for your Ruby projects.

## See Also

- [sus-vscode](https://github.com/socketry/sus-vscode) - Visual Studio Code extension for Sus.

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
