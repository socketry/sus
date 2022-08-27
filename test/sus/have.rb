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
end
