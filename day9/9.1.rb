require_relative "../utils"
require 'benchmark'
Coord = Struct.new('Coord', :row, :col)
Rectange = Struct.new('Rectangle', :coord_a, :coord_b, :area)

def area(coord_a, coord_b)
  row_diff = (coord_a.row - coord_b.row).abs + 1
  col_diff = (coord_a.col - coord_b.col).abs + 1
  row_diff * col_diff
end

def largest_rect(positions)
  row_sorted_coords = sort_by_row(positions)
  
  # Remove duplicate coordinates (same row and col)
  row_sorted_coords.uniq! { |c| [c.row, c.col] }
  
  max_area = 0

  row_sorted_coords.each_with_index do |coord_a, coord_a_idx|
    row_sorted_coords.each_with_index do |coord_b, coord_b_idx|
      next if coord_a_idx >= coord_b_idx
      current_area = area(coord_a, coord_b)
      max_area = current_area if current_area > max_area
    end  
  end
  
  max_area
end

def sort_by_row(string_positions)
  coords = string_positions
    .reject(&:empty?)
    .map(&:strip)  # Remove whitespace
    .select { |pos| pos.include?(',') }  # Only process entries with a comma
    .map do |string_position|
      array = string_position.split(',')
      next if array.length != 2  # Skip malformed entries
      col = array[0].strip.to_i
      row = array[1].strip.to_i
      Coord.new(row, col)
    end
    .compact  # Remove any nil values from malformed entries
  coords.sort_by! {|coord| coord.row }
end

####################################
raw_data = fetch_puzzle_input(9)
# Handle case where data might be a string that needs splitting
REAL_DATA = raw_data.is_a?(String) ? raw_data.split("\n") : raw_data
# col, row - 0 indexed
TEST_DATA = ["7,1", "11,1", "11,7", "9,7", "9,5", "2,5", "2,3", "7,3"]

puts "Running test 1"
result = largest_rect(TEST_DATA)
puts result === 50 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = largest_rect(REAL_DATA)
puts colorize("Result: #{result}", 36)
puts "Expected: (check if this matches your puzzle answer)"

# puts "Running test 2"
# result = connecting_coord_x_distance(TEST_DATA)
# puts result === 25272 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = connecting_coord_x_distance(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 3926518899 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)
