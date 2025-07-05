# Sus

Sus is a testing framework for Ruby.

  - It's similar to RSpec but with less baggage and more parallelism.
  - It uses `expect` style syntax with first-class predicates.
  - It has direct [support for code coverage](https://github.com/socketry/covered).
  - It supports the [VSCode Test Runner interface](https://github.com/socketry/sus-vscode).
  - It's based on my experience writing thousands of tests.
  - It's easy to extend (see the `sus-fixtures-` gems for examples).

[![Development Status](https://github.com/socketry/sus/workflows/Test/badge.svg)](https://github.com/socketry/sus/actions?workflow=Test)

## Lightning Talk: Testing with Sus (2023)

<div align="center">
  <a href="https://www.youtube.com/watch?v=BDQHgb2rrwU">
    <img src="https://img.youtube.com/vi/BDQHgb2rrwU/0.jpg" alt="Testing with Sus"/>
  </a>
</div>

## Usage

Please see the [project documentation](https://socketry.github.io/sus/) for more details.

  - [Getting Started](https://socketry.github.io/sus/guides/getting-started/index) - This guide explains how to use the `sus` gem to write tests for your Ruby projects.

## Releases

Please see the [project releases](https://socketry.github.io/sus/releases/index) for all releases.

### v0.33.0

  - Add support for `agent-context` gem.
  - [`receive` now supports blocks and `and_raise`.](https://socketry.github.io/sus/releases/index#receive-now-supports-blocks-and-and_raise.)

### v0.32.0

  - `Sus::Config` now has a `prepare_warnings!` hook which enables deprecated warnings by default. This is generally considered good behaviour for a test framework.

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
