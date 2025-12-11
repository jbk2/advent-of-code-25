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

  # puts "Total coords: #{coords.length}"
  # puts "First coord: #{coords.first.inspect}"
  # puts "Last coord: #{coords.last.inspect}"
  # coords_length = row_sorted_coords.length
  # memo
  all_rects = {}

  row_sorted_coords.each_with_index do |coord_a, coord_a_idx|
    row_sorted_coords.each_with_index do |coord_b, coord_b_idx|
      next if coord_a_idx >= coord_b_idx
      all_rects[[coord_a, coord_b]] = area(coord_a, coord_b)
    end  
  end
  all_rects.values.max
end

def sort_by_row(string_positions)
  coords = string_positions.reject(&:empty?).map do |string_position|
    array = string_position.split(',')
    Coord.new(array[1].to_i, array[0].to_i)
  end
  coords.sort_by! {|coord| coord.row }
end

####################################
REAL_DATA = fetch_puzzle_input(9)
# col, row - 0 indexed
TEST_DATA = ["7,1", "11,1", "11,7", "9,7", "9,5", "2,5", "2,3", "7,3"]
# puts sort_by_row(TEST_DATA).each_cons(1) { |e| area(e[0], e[1]) }.inspect 
# puts largest_rect(TEST_DATA)
# puts largest_rect(TEST_DATA).each {|e| puts e.inspect }
puts REAL_DATA.inspect

puts "Running test 1"
result = largest_rect(TEST_DATA)
puts result === 50 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = largest_rect(REAL_DATA)
puts result === 0 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = connecting_coord_x_distance(TEST_DATA)
# puts result === 25272 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = connecting_coord_x_distance(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 3926518899 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)