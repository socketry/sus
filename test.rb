#!/usr/bin/env ruby

class Thing
	def bar
		"foo"
	end
end

class Mock1
	def initialize(target)
		@target = target
		@interceptor = Module.new
		
		@target.singleton_class.prepend(@interceptor)
	end
	
	def clear
		@interceptor.instance_methods.each do |method_name|
			@interceptor.remove_method(method_name)
		end
	end
	
	def intercept(method, &block)
		@interceptor.define_method(method, &block)
	end
end

class Mock2
	def initialize(target)
		@target = target
		@methods = []
	end
	
	def clear
		@methods.each do |method_name|
			@target.singleton_class.remove_method(method_name)
		end
	end
	
	def intercept(method, &block)
		@target.singleton_class.define_method(method, &block)
	end
end

require 'benchmark'

n = 100
Benchmark.bm do |x|
	x.report do
		n.times do
			thing = Thing.new
			mock = Mock1.new(thing)
			mock.intercept(:bar) {"foo"+super()}
			thing.bar
			mock.clear
		end
	end

	x.report do
		n.times do
			thing = Thing.new
			mock = Mock2.new(thing)
			mock.intercept(:bar) {"foo"+super()}
			thing.bar
			mock.clear
		end
	end
end
