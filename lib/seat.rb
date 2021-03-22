# frozen_string_literal: true

class Seat
  attr_reader \
    :aisle,
    :centrality,
    :id,
    :pivot_aisle,
    :row,
    :status

  alias column aisle
  alias to_s id
  alias inspect id

  include Comparable

  def self.new_from_collection(attrs_list, pivot_aisle:)
    attrs_list.map { |attrs| new(**attrs, pivot_aisle: pivot_aisle) }
  end

  def initialize(id:, row:, column:, status:, pivot_aisle:)
    self.id = id.to_s.upcase
    self.row = row.to_s.upcase
    self.aisle = column.to_i
    self.status = status.to_s
    self.pivot_aisle = pivot_aisle
    self.centrality = calculate_centrality
  end

  def available?
    status == "AVAILABLE"
  end

  def <=>(other)
    centrality <=> other.centrality
  end

  private

  attr_writer \
    :aisle,
    :centrality,
    :id,
    :pivot_aisle,
    :row,
    :status

  def calculate_centrality
    row_distance = row.ord - "A".ord
    aisle_distance = aisle - pivot_aisle

    row_distance + aisle_distance.abs
  end
end
