# frozen_string_literal: true

require "concentric_array"
require "seat"

class Venue
  attr_reader :aisles, :rows, :seats
  alias columns aisles

  def initialize(columns:, rows:, seats:)
    # temp: fail loudly if > 26 rows
    raise ArgumentError if rows > 26

    self.rows = ("A".."Z").take(rows)
    self.aisles = ConcentricArray.new((1..columns).entries)
    self.seats = Seat.new_from_collection(seats, pivot_aisle: aisles.pivot_element)
  end

  # Find `number` available seats, in descending order of centrality.
  # If `as_group` is truthy, return `number` available adjacent seats.
  #
  # Return an array.
  def find_seats(number:, as_group: false)
    available_seats = seats.select(&:available?).sort

    return available_seats.first(number) unless as_group

    seats_index =
      available_seats.group_by(&:id).transform_values(&:first)

    available_seats
      .map { |seat| adjacent_seats(seat, seats_index, number: number) }
      .find { |seating_group| seating_group.length == number }
      .to_a
  end

  private

  attr_writer :aisles, :rows, :seats

  def adjacent_seats(seat, available_seats_index, number: 1)
    return [] unless number.positive?

    aisles
      .slice(pivot_index: seat.aisle.pred, length: number)
      .take(number)
      .map { |aisle_num| [seat.row, aisle_num].join }
      .sort
      .map { |seat_id| available_seats_index[seat_id] }
      .compact
  end
end
