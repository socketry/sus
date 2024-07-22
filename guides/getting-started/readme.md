# Getting Started

This guide explains how to use the `sus` gem to write tests for your Ruby projects.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add sus
~~~

## Write Some Tests

Create a test file in your project `test/my_project/my_class.rb`:

~~~ ruby
describe MyProject::MyClass do
	let(:instance) {subject.new}
	
	it "instantiates an object" do
		expect(instance).to be_a(Object)
	end
end
~~~

## Run Your Tests

Run your tests with the `sus` command:

~~~ bash
$ sus
~~~

You can also run your tests in parallel:

~~~ bash
$ sus-parallel
~~~
