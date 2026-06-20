# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

describe Sus::Filter do
	FakeIdentity = Struct.new(:key)
	
	class FakeRegistry
		def initialize(child)
			@child = child
			@loaded = []
			@called = false
		end
		
		attr :loaded
		attr :called
		
		def children
			{FakeIdentity.new("test.rb:1") => @child}
		end
		
		def load(path)
			@loaded << path
		end
		
		def each
			yield @child
		end
		
		def call(assertions)
			@called = true
		end
	end
	
	let(:child) {Sus::It.build(Sus.base, "child"){assert(true)}}
	let(:registry) {FakeRegistry.new(child)}
	let(:filter) {subject.new(registry)}
	
	it "delegates to the registry without a filter" do
		filter.load("test.rb")
		
		collected = []
		filter.each{|item| collected << item}
		filter.call(Sus::Assertions.new)
		
		expect(registry.loaded).to be == ["test.rb"]
		expect(collected).to be == [child]
		expect(registry.called).to be == true
	end
	
	it "filters by identity key" do
		filter.load("test.rb:1")
		
		collected = []
		filter.each{|item| collected << item}
		
		assertions = filter.call(Sus::Assertions.new)
		
		expect(registry.loaded).to be == ["test.rb"]
		expect(collected).to be == [child]
		expect(assertions.count).to be == 1
	end
	
	it "detects duplicate identity keys" do
		index = Sus::Filter::Index.new
		identity = FakeIdentity.new("duplicate")
		
		index.insert(identity, child)
		
		expect do
			index.insert(identity, child)
		end.to raise_exception(KeyError, message: be =~ /duplicate/)
	end
end
