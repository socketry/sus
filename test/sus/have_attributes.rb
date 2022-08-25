User = Struct.new(:name, :age)

describe User.new("Sus", 20) do
	it {is_expected.to have_attributes(name: be == "Sus", age: be >= 20)}
end

describe ->{raise "Boom"} do
	it {is_expected.to raise_exception(RuntimeError, message: "Boom")}
end
