# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "json"

describe Sus::Tree do
	let(:root) {Sus::Describe.build(Sus.base, "root")}
	let(:child) {Sus::It.build(root, "child"){}}
	let(:tree) {subject.new(root)}
	
	def before
		root.add(child)
	end
	
	it "can traverse contexts" do
		result = tree.traverse do |context|
			context.description
		end
		
		expect(result).to be == {
			self: "root",
			children: [
				{self: "child"}
			]
		}
	end
	
	with "#to_json" do
		it "can be converted to JSON" do
			result = JSON.parse(tree.to_json)
			
			expect(result["self"]).to be == [root.identity.to_s, "root", false]
			expect(result["children"].first["self"]).to be == [child.identity.to_s, "child", true]
		end
	end
end
