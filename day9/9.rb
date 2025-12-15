require_relative "../utils"
require 'benchmark'

Coord = Struct.new('Coord', :row, :col, :color) do
  def initialize(row, col, color = 'red')
    super(row, col, color)
  end
end

Rectange = Struct.new('Rectangle', :coord_a, :coord_b, :area)

def area(coord_a, coord_b)
  row_diff = (coord_a.row - coord_b.row).abs + 1
  col_diff = (coord_a.col - coord_b.col).abs + 1
  row_diff * col_diff
end

def largest_rect(positions)
  coord_data = create_coords(positions)
  sorted_coord_data = coord_data.sort_by! {|coord| coord.row }
  all_rects = {}

  sorted_coord_data.each_with_index do |coord_a, coord_a_idx|
    sorted_coord_data.each_with_index do |coord_b, coord_b_idx|
      next if coord_a_idx >= coord_b_idx
      all_rects[[coord_a, coord_b]] = area(coord_a, coord_b)
    end  
  end
  all_rects.values.max
end

def create_coords(string_positions)
  coords = string_positions.reject(&:empty?).map(&:strip).map do |string_position|
    array = string_position.split(',')
    Coord.new(array[1].to_i, array[0].to_i)
  end
end

def create_polygon(input)
  red_tile_coords = create_coords(input)
  all_tiles = red_and_green_tiles(red_tile_coords)
  puts all_tiles
  
end

def red_and_green_tiles(red_tile_coords)
  red_and_green_tiles = []
  red_tile_coords.each_with_index do |coord_a, coord_a_index|
    coord_b = red_tile_coords[(coord_a_index + 1) % red_tile_coords.length]
    
    if coord_a.row == coord_b.row
       # coord_b could be either higher or lower tha coord_a on either axis so,
       # count in the correct direction from a to b
      step = coord_a.col < coord_b.col ? 1 : -1
      col = coord_a.col < coord_b.col ? coord_a.col + 1 : coord_a.col - 1
      red_and_green_tiles << coord_a

      while col != coord_b.col
        red_and_green_tiles << Coord.new(coord_a.row, col, 'green')
        col += step
      end
    elsif coord_a.col == coord_b.col
      step = coord_a.row < coord_b.row ? 1 : -1
      row = coord_a.row < coord_b.row ? coord_a.row + 1 : coord_a.row - 1
      red_and_green_tiles << coord_a

      while row != coord_b.row
        red_and_green_tiles << Coord.new(row, coord_a.col, 'green')
        row += step
      end
    end
  end
  fill_polygon_interior(red_and_green_tiles)
end

def fill_polygon_interior(red_and_green_tiles)
  red_and_green_tiles
  
end

####################################
REAL_DATA = fetch_puzzle_input(9)
# col, row - 0 indexed
TEST_DATA = ["7,1", "11,1", "11,7", "9,7", "9,5", "2,5", "2,3", "7,3"]
# puts sort_by_row(TEST_DATA).each_cons(1) { |e| area(e[0], e[1]) }.inspect 
# puts largest_rect(TEST_DATA)
# puts largest_rect(TEST_DATA).each {|e| puts e.inspect }
# puts REAL_DATA.inspect

puts "Running test 1"
result = largest_rect(TEST_DATA)
puts result === 50 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = largest_rect(REAL_DATA)
puts result === 4748769124 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running test 2"
result = create_polygon(TEST_DATA)
puts result === 0 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = connecting_coord_x_distance(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 3926518899 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)