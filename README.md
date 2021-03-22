SeatSelectionService
====================

Walkthrough
-----------

```rb
# lib/seat_selection_service.rb L6-21 (f5f77421)

class SeatSelectionService
  def self.best_available_seat(venue_info_json:, number: 1, as_group: false)
    venue_info =
      JSON.parse(venue_info_json, symbolize_names: true)

    venue_attrs =
      venue_info
        .dig(:venue, :layout)
        .merge(seats: venue_info[:seats].values)

    Venue
      .new(**venue_attrs)
      .find_seats(number: number, as_group: as_group)
      .map(&:to_s)
  end
end
```

A `Venue` and `Seat` model each manages logic pertaining to properties of their respective entities.

```rb
# lib/venue.rb L19-35 (f5f77421)

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
```

```rb
# lib/seat.rb L35-54 (f5f77421)

def <=>(other)
  centrality <=> other.centrality
end

# . . .

def calculate_centrality
  row_distance = row.ord - "A".ord
  aisle_distance = aisle - pivot_aisle

  row_distance + aisle_distance.abs
end
```

Logic for iterating outward from the center of an aisle is provided by a `ConcentricArray` utility class:

```rb
# lib/concentric_array.rb L15-24 (e05f7785)

def entries
  return [] if elements.empty?

  (1..pivot.succ)
    .map { |offset| [pivot - offset, pivot + offset] }
    .flat_map { |lhs, rhs| [(lhs if lhs >= 0), (rhs if rhs < length)] }
    .compact
    .unshift(pivot)
    .map { |index| elements[index] }
end
```

Tests
-----

To accommodate development time constraints, only unit tests of the utility class `ConcentricArray` and integration tests of `SeatSelectionService` are included.

```
% bundle exec rspec

ConcentricArray
  #entries
    given an enumerable of odd length
      returns its elements in an order expanding outward from its central pivot
    given an enumerable of even length
      returns its elements in an order expanding outward from its central pivot
  #pivot
    given an elements collection of even length
      returns the zero-based index of the left-biased middle element
    given an elements collection of odd length
      returns the zero-based index of the middle element

SeatSelectionService
  .best_available_seat
    given a request for a group of seats
      returns an empty array if no seating group is available
      returns the group of same-aisle seats closest to center front
    given a request for a single seat
      returns the seat closest to center front
    given a booked first row
      returns the seat closest to center front in the second row
    given a request for multiple seats
      returns the seats closest to center front, not necessarily as a group

Finished in 0.00437 seconds (files took 0.09863 seconds to load)
9 examples, 0 failures

Randomized with seed 5126

```
