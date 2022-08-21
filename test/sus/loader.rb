describe Sus::Loader do
	it "has a correct require_root" do
		expect(self.class.require_root).to be == File.expand_path("../../", __dir__)
	end
end
