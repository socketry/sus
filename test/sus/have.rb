# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

User = Struct.new(:name, :age)

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
	
	describe Array do
		let(:array) {[1, 2, 3]}
		
		it "can contain a value" do
			expect(array).to have_value(be == 1)
			expect(array).to have_value(be == 2)
			expect(array).to have_value(be == 3)
		end
		
		it "doesn't contain a value" do
			expect(array).not.to have_value(be == 4)
			expect(array).not.to have_value(be < 1)
		end
	end
end
