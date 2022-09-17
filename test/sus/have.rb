# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

User = Struct.new(:name, :age)

describe Sus::Have do
	describe User.new("Sus", 20) do
		it {is_expected.to have_attributes(
			name: be == "Sus",
			age: be >= 20
		)}
	end
	
	describe({:name => "Sus", 'age' => 20}) do
		it {is_expected.to have_keys(
			:name => be == "Sus",
			"age" => be >= 20
		)}
		
		it {is_expected.to have_keys(
			:name, "age"
		)}
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
