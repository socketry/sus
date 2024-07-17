# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

User = Struct.new(:name, :age)

require 'socket'

describe Sus::Have do
	describe User do
		let(:user) {subject.new("Sus", 20)}
		
		it "has name and age" do
			expect(user).to have_attributes(
				name: be == "Sus",
				age: be >= 20
			)
		end
	end
	
	describe Hash do
		let(:hash) {subject[:name => "Sus", "age" => 20]}
		
		it 'has keys with values' do
			expect(hash).to have_keys(
				:name => be == "Sus",
				"age" => be >= 20
			)
		end
		
		it 'has keys' do 
			expect(hash).to have_keys(
				:name, "age"
			)
		end
	end
	
	describe Socket do
		def before
			super
			
			@socket = Socket.new(:INET, :STREAM)
		end
		
		def after
			@socket.close
			
			super
		end
		
		it 'can use have_attributes on object that defines #send' do
			skip_unless_method_defined(:timeout, Socket)
			
			expect(@socket).to have_attributes(timeout: be_nil)
		end
	end
	
	describe Array do
		let(:array) {[1, 2, 3]}
		
		it "can contain a value" do
			expect(array).to have_value(be == 1)
			expect(array).to have_value(be == 2)
			expect(array).to have_value(be == 3)
		end
		
		it "reports a single failure" do
			assertions = Sus::Assertions.new
			Sus::Expect.new(assertions, array).to have_value(be == 4)
			
			expect(assertions.failed).to have_attributes(size: be == 1)
		end
		
		it "doesn't contain a value" do
			expect(array).not.to have_value(be == 4)
			expect(array).not.to have_value(be < 1)
		end
	end
	
	describe Hash do
		let(:values) {[{a: 1}, {b: 2}, {c: 3}]}
		
		it "can contain keys" do
			expect(values).to have_value(have_keys(a: be == 1))
		end
		
		it "doesn't contain keys" do
			expect(values).not.to have_value(have_keys(a: be == 2))
			expect(values).not.to have_value(have_keys(d: be == 4))
		end
	end
end
