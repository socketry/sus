
class Foo
	def top_level?
		false
	end
end

describe '#in_isolation' do
	in_isolation do
		class Foo
			def top_level?
				false
			end
		end
	end
	
	it "should not be top level" do
		expect(Foo.new).to be(:top_level?)
		expect(in_isolation{Foo.new}).not.to be(:top_level?)
	end
end
