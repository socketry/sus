describe Sus::Identity do
	with 'basic identifier' do
		def identifier
			subject.new("file.rb", "file", 123)
		end
		
		it "can generate unique identifier" do
			expect(identifier.key).to be == "file.rb:123"
		end
	end
	
	with 'nested unique identifiers' do
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
	
	with 'nested non-unique identifiers' do
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
	
	with 'nested non-unique named identifiers' do
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
end
