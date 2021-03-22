# frozen_string_literal: true

require "json"
require "venue"

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
