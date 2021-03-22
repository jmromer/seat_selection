# frozen_string_literal: true

require "concentric_array"

describe ConcentricArray do
  describe "#entries" do
    context "given an enumerable of odd length" do
      it "returns its elements in an order expanding outward from its central pivot" do
        c_array = ConcentricArray.new([1])
        expect(c_array.entries).to eq([1])

        c_array = ConcentricArray.new((1..3).entries)
        expect(c_array.entries).to eq([2, 1, 3])

        c_array = ConcentricArray.new((1..5).entries)
        expect(c_array.entries).to eq([3, 2, 4, 1, 5])

        c_array = ConcentricArray.new((3..9).entries)
        expect(c_array.entries).to eq([6, 5, 7, 4, 8, 3, 9])

        c_array = ConcentricArray.new(one: 1, two: 2, three: 3)
        expect(c_array.entries.to_h).to eq(two: 2, one: 1, three: 3)
      end
    end

    context "given an enumerable of even length" do
      it "returns its elements in an order expanding outward from its central pivot" do
        c_array = ConcentricArray.new([])
        expect(c_array.entries).to eq([])

        c_array = ConcentricArray.new((1..2).entries)
        expect(c_array.entries).to eq([1, 2])

        c_array = ConcentricArray.new((1..8).entries)
        expect(c_array.entries).to eq([4, 3, 5, 2, 6, 1, 7, 8])

        c_array = ConcentricArray.new((1..12).entries)
        expect(c_array.entries).to eq([6, 5, 7, 4, 8, 3, 9, 2, 10, 1, 11, 12])

        c_array = ConcentricArray.new((4..9).entries)
        expect(c_array.entries).to eq([6, 5, 7, 4, 8, 9])

        c_array = ConcentricArray.new(one: 1, two: 2, three: 3, four: 4)
        expect(c_array.entries.to_h).to eq(two: 2, one: 1, three: 3, four: 4)
      end
    end
  end

  describe "#pivot" do
    context "given an elements collection of odd length" do
      it "returns the zero-based index of the middle element" do
        c_array = ConcentricArray.new([1])
        expect(c_array.pivot).to eq(0)

        c_array = ConcentricArray.new((1..3).entries)
        expect(c_array.pivot).to eq(1)

        c_array = ConcentricArray.new((1..5).entries)
        expect(c_array.pivot).to eq(2)

        c_array = ConcentricArray.new((3..9).entries)
        expect(c_array.pivot).to eq(3)
      end
    end

    context "given an elements collection of even length" do
      it "returns the zero-based index of the left-biased middle element" do
        c_array = ConcentricArray.new([])
        expect(c_array.pivot).to eq(nil)

        c_array = ConcentricArray.new((1..2).entries)
        expect(c_array.pivot).to eq(0)

        c_array = ConcentricArray.new((1..8).entries)
        expect(c_array.pivot).to eq(3)

        c_array = ConcentricArray.new((1..12).entries)
        expect(c_array.pivot).to eq(5)
      end
    end
  end
end
