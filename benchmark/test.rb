# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

ITERATIONS = ENV.fetch("ITERATIONS", 1000).to_i
TYPE = ENV.fetch("TYPE", "pos")

describe "sus" do
  ITERATIONS.times do |n|
    case TYPE
    when "pos" then
      it "pos #{n}" do
        expect(1).to be == 1
      end
    when "neg" then
      it "neg #{n}" do
        expect(1).to be == 2
      end
    end
  end
end
