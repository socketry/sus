#!/usr/bin/env ruby

class Base
	def self.print
	end
end

module Foo
	attr_accessor :foo
	
	def print
		self.superclass.print
		puts "Foo: #{self.name} #{foo}"
	end
end

module Bar
	attr_accessor :bar
	
	def print
		self.superclass.print
		puts "Bar: #{self.name} #{bar}"
	end
end

C1 = Class.new(Base)
# C1.extend(Foo)
C1.singleton_class.prepend(Foo)
C1.foo = 10

C2 = Class.new(C1)
# C2.extend(Bar)
C2.singleton_class.prepend(Bar)
C2.bar = 20

C3 = Class.new(C2)
# C3.extend(Foo)
C3.singleton_class.prepend(Foo)
C3.foo = 30

C3.print

binding.irb
