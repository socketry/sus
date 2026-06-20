# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

describe Sus::Identity do
	with "basic identifier" do
		def identifier
			subject.new("file.rb", "file", 123)
		end
		
		it "can generate unique identifier" do
			expect(identifier.key).to be == "file.rb:123"
		end
	end
	
	with "nested unique identifiers" do
		def parent
			subject.new("file1.rb", "file1", 10)
		end
		
		def identifier
			subject.new("file2.rb", "file2", 20, parent)
		end
		
		it "can generate unique identifier" do
			expect(identifier.key).to be == "file1.rb:20"
		end
	end
	
	with "nested non-unique identifiers" do
		def parent
			subject.new("file1.rb", "file1", 10, unique: false)
		end
		
		def identifier
			subject.new("file2.rb", "file2", 20, parent, unique: false)
		end
		
		it "can generate unique identifier" do
			expect(identifier.key).to be == "file1.rb:10:20"
		end
	end
	
	with "nested non-unique named identifiers" do
		def parent
			subject.new("file1.rb", "file1", 10, unique: "one")
		end
		
		def identifier
			subject.new("file2.rb", "file2", 20, parent, unique: false)
		end
		
		it "can generate unique identifier" do
			expect(identifier.key).to be == "file1.rb:one:20"
		end
	end
	
	with "#scoped" do
		let(:identifier) {subject.new(__FILE__, "test")}
		
		it "can scope an identifier to the current caller" do
			line_number = __LINE__ + 1
			scoped_identifier = identifier.scoped
			expect(scoped_identifier.key).to be == "#{__FILE__}:#{line_number}"
		end
		
		it "can scope an identifier to an explicit location" do
			location = caller_locations(1, 1).first
			identifier = subject.new(location.path, "test")
			
			scoped_identifier = identifier.scoped([location])
			
			expect(scoped_identifier.line).to be == location.lineno
		end
	end
	
	with "#to_location" do
		it "returns an expanded path and line" do
			location = subject.new("file.rb", "file", 123).to_location
			
			expect(location[:path]).to be == File.expand_path("file.rb")
			expect(location[:line]).to be == 123
		end
	end
	
	with "#match?" do
		let(:identifier) {subject.new("file.rb", "file", 123)}
		
		it "matches another identity" do
			expect(identifier.match?(subject.new("file.rb", "file", 123))).to be_nil
		end
		
		it "does not match a different path" do
			expect(identifier.match?(subject.new("other.rb", "file", 123))).to be == false
		end
		
		it "does not match a different name" do
			expect(identifier.match?(subject.new("file.rb", "other", 123))).to be == false
		end
		
		it "does not match a different line" do
			expect(identifier.match?(subject.new("file.rb", "file", 456))).to be == false
		end
	end
	
	with "#each" do
		it "enumerates parent identities first" do
			parent = subject.new("parent.rb", "parent", 1)
			child = subject.new("child.rb", "child", 2, parent)
			identities = []
			child.each{|identity| identities << identity}
			
			expect(identities).to be == [parent, child]
		end
	end
end
