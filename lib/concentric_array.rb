# frozen_string_literal: true

class ConcentricArray
  include Enumerable

  attr_reader :elements, :length, :pivot, :pivot_element

  def initialize(elements)
    self.elements = Array(elements)
    self.length = self.elements.length
    self.pivot = pivot_index
    self.pivot_element = elements[pivot] unless pivot.nil?
  end

  def entries
    return [] if elements.empty?

    (1..pivot.succ)
      .map { |offset| [pivot - offset, pivot + offset] }
      .flat_map { |lhs, rhs| [(lhs if lhs >= 0), (rhs if rhs < length)] }
      .compact
      .unshift(pivot)
      .map { |index| elements[index] }
  end

  # Iterate through the collection's elements in ascending order of distance
  # from the pivot element at its center. Ties are resolved left-biased (the
  # leftmost element has precedence.)
  def each
    entries.each { |entry| yield(entry) if block_given? }
  end

  # Return a new concentric array, composed of a slice from the elements of
  # `self`, of maximum length `length`, centered on the given `pivot_index`.
  def slice(pivot_index:, length: 1)
    start_i = pivot_index - length
    end_i = pivot_index + length
    sliced_elements = elements[start_i..end_i].reject(&:negative?).compact
    self.class.new(sliced_elements)
  end

  private

  attr_writer :elements, :length, :pivot, :pivot_element

  def pivot_index
    return if elements.empty?
    return length / 2 if length.odd?

    (length / 2).pred
  end
end
