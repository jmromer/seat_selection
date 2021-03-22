# frozen_string_literal: true

require "json"
require "seat_selection_service"

describe SeatSelectionService do
  describe ".best_available_seat" do
    context "given a request for a single seat" do
      it "returns the seat closest to center front" do
        json = venue_json(rows: 10, aisles: 12, available_seats: %w[a6])
        result = described_class.best_available_seat(venue_info_json: json)
        expect(result).to eq(%w[A6])
      end
    end

    context "given a booked first row" do
      it "returns the seat closest to center front in the second row" do
        available_seats = (1..12).map { |n| "b#{n}" }
        json = venue_json(rows: 10, aisles: 12, available_seats: available_seats)
        result = described_class.best_available_seat(venue_info_json: json)
        expect(result).to eq(%w[B6])

        available_seats = (1..5).map { |n| "b#{n}" }
        json = venue_json(rows: 10, aisles: 5, available_seats: available_seats)
        result = described_class.best_available_seat(venue_info_json: json)
        expect(result).to eq(%w[B3])
      end
    end

    context "given a request for multiple seats" do
      it "returns the seats closest to center front, not necessarily as a group" do
        available_seats = %w[a6 a8 b4 b6 b12]
        json = venue_json(rows: 10, aisles: 12, available_seats: available_seats)
        result = described_class.best_available_seat(venue_info_json: json, number: 4)
        expect(result).to eq(%w[A6 B6 A8 B4])
      end
    end

    context "given a request for a group of seats" do
      it "returns the group of same-aisle seats closest to center front" do
        available_seats = (1..12).map { |n| "a#{n}" }
        json = venue_json(rows: 10, aisles: 12, available_seats: available_seats)
        result = described_class.best_available_seat(venue_info_json: json, number: 3, as_group: true)
        expect(result).to eq(%w[A5 A6 A7])

        available_seats = (1..5).map { |n| "b#{n}" }
        json = venue_json(rows: 10, aisles: 5, available_seats: available_seats)
        result = described_class.best_available_seat(venue_info_json: json, number: 2, as_group: true)
        expect(result).to eq(%w[B2 B3])
      end

      it "returns an empty array if no seating group is available" do
        available_seats = %w[a6 a8 b4 b6 b12]
        json = venue_json(rows: 10, aisles: 12, available_seats: available_seats)
        result = described_class.best_available_seat(venue_info_json: json, number: 3, as_group: true)
        expect(result).to eq([])
      end
    end
  end

  def venue_json(rows: 10, aisles: 10, available_seats: [])
    JSON.dump(
      venue: { layout: { rows: rows, columns: aisles } },
      seats: available_seats.map { |id| [id, to_seat_object(id)] }.to_h,
    )
  end

  def to_seat_object(seat_id)
    components =
      seat_id.match(/\A(?<row>[[:alpha:]]+)(?<aisle>[[:digit:]]+)\z/)
    {
      id: seat_id,
      row: components[:row],
      column: components[:aisle].to_i,
      status: "AVAILABLE",
    }
  end
end
