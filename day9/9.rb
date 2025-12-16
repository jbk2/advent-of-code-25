require_relative "../utils"
require 'benchmark'
require 'set'

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
  string_positions.reject(&:empty?).map(&:strip).map do |string_position|
    array = string_position.split(',')
    Coord.new(array[1].to_i, array[0].to_i)
  end
end

# def contents_all_tiles?(all_tiles_set, coord_a, coord_b)
#   min_row, max_row = [coord_a.row, coord_b.row].minmax
#   min_col, max_col = [coord_a.col, coord_b.col].minmax
#   row_range, col_range = (min_row..max_row), (min_col..max_col)

#   row_range.all? do |row|
#     col_range.all? do |col|
#       all_tiles_set.include?([row, col])
#     end
#   end
# end

def point_in_polygon?(row, col, red_tiles)
  inside = false
  last_tile_idx = red_tiles.length - 1
  prev_tile_idx = last_tile_idx

  red_tiles.each_with_index do |current_tile, current_tile_idx|
    prev_tile = red_tiles[prev_tile_idx]

    # Check if edge crosses the horizontal line through our point
    edge_crosses = (current_tile.row > row) != (prev_tile.row > row)

    if edge_crosses
      # Skip horizontal edges (division by zero check)
      unless prev_tile.row == current_tile.row
        # Calculate intersection point
        intersection_col = (prev_tile.col - current_tile.col) * (row - current_tile.row) /
                           (prev_tile.row - current_tile.row).to_f + current_tile.col
        if col < intersection_col
          inside = !inside
        end
      end
    end
    prev_tile_idx = current_tile_idx
  end
  
  inside
end

# def on_boundary?(row, col, red_tiles)
#   red_tiles.each_with_index do |coord_a, idx|
#     coord_b = red_tiles[(idx + 1) % red_tiles.length]
    
#     if coord_a.row == coord_b.row && coord_a.row == row
#       min_col, max_col = [coord_a.col, coord_b.col].minmax
#       return true if col >= min_col && col <= max_col
#     elsif coord_a.col == coord_b.col && coord_a.col == col
#       # Same col - check if row is between them (inclusive)
#       min_row, max_row = [coord_a.row, coord_b.row].minmax
#       return true if row >= min_row && row <= max_row
#     end
#   end
#   false
# end

def largest_filled_rect(input)
  red_tiles = create_coords(input)
  rows, cols, r_idx, c_idx = build_compressed_axes(red_tiles)
  grid = build_boundary_grid(red_tiles, rows, cols, r_idx, c_idx)
  fill_grid_outside_boundary!(grid)

  max_area = 0

  red_tiles.each_with_index do |tile_a, tile_a_idx|
    red_tiles.each_with_index do |tile_b, tile_b_idx|
      next if tile_a_idx >= tile_b_idx

      min_row, max_row = [tile_a.row, tile_b.row].minmax
      min_col, max_col = [tile_a.col, tile_b.col].minmax

      rect_area = (max_row - min_row + 1) * (max_col - min_col + 1)
      next if rect_area <= max_area

      next unless rectangle_enclosed?(min_row, max_row, min_col, max_col, r_idx, c_idx, grid)
      
      max_area = rect_area
    end
  end

  max_area
end

def build_compressed_axes(red_tiles)
  min_row, max_row = red_tiles.map(&:row).minmax
  min_col, max_col = red_tiles.map(&:col).minmax

  # compress grid lines/tile edges, not tile centers
  row_edges = Set.new([min_row - 1, max_row + 2])
  col_edges = Set.new([min_col - 1, max_col + 2])

  red_tiles.each do |t|
    # Tile Y edges; [row,row+1), tile X edges; [col,col+1)
    [t.row, t.row + 1].each { row_edges.add(_1) }
    [t.col, t.col + 1].each { col_edges.add(_1) }
  end

  rows = row_edges.to_a.sort
  cols = col_edges.to_a.sort

  r_idx = {} # hash data map, key is row value, value is index position of that value within rows 
  rows.each_with_index { |v, i| r_idx[v] = i }
  c_idx = {}
  cols.each_with_index { |v, i| c_idx[v] = i }

  [rows, cols, r_idx, c_idx]
end

def build_boundary_grid(red_tiles, rows, cols, r_idx, c_idx)
  height = rows.length - 1
  width = cols.length - 1
  grid = Array.new(height) { Array.new(width, ".") }

  # Mark boundary tiles with '#'
  red_tiles.each_with_index do |tile_a, tile_a_idx|
    tile_b = red_tiles[(tile_a_idx + 1) % red_tiles.length]

    if tile_a.row == tile_b.row
      row = r_idx[tile_a.row]
      min_col, max_col = [tile_a.col, tile_b.col].minmax
      start = c_idx[min_col]
      finish = c_idx[max_col + 1] - 1
      (start..finish).each { |col| grid[row][col] = '#' }
    else
      col = c_idx[tile_a.col]
      min_row, max_row = [tile_a.row, tile_b.row].minmax
      start = r_idx[min_row]
      finish = r_idx[max_row + 1] - 1
      (start..finish).each { |row| grid[row][col] = '#' }
    end
  end

  grid
end

def fill_grid_outside_boundary!(grid)
  height = grid.length
  width = grid[0].length

  stack = [[0, 0]] # definitely outside due to padding
  directions = [[1, 0],[-1, 0],[0, 1],[0, -1]]

  while (cell = stack.pop)
    row, col = cell
    next if row < 0 || row >= height || col < 0 || col >= width
    next unless grid[row][col] == '.'
    grid[row][col] = 'O'

    directions.each do |dr, dc|
      stack << [row + dr, col + dc]
    end
  end
end

def rectangle_enclosed?(min_row, max_row, min_col, max_col, r_idx, c_idx, grid)
  top, bottom = r_idx[min_row], r_idx[max_row]
  left, right = c_idx[min_col], c_idx[max_col]

  valid = ->(row, col) { grid[row][col] != 'O' }

  (left..right).each do |col|
    return false unless valid.call(top, col)
    return false unless valid.call(bottom, col)
  end

  (top..bottom).each do |row|
    return false unless valid.call(row, left)
    return false unless valid.call(row, right)
  end

  true
end

# def build_valid_area_prefix_sum(outside, rows, cols)
#   h = outside.length
#   w = outside[0].length
#   prefix = Array.new(h + 1) { Array.new(w + 1, 0) }

#   (0...h).each do |i|
#     row_sum = 0
#     (0...w).each do |j|
#       cell_area = outside[i][j] ? 0 : (rows[i + 1] - rows[i]) * (cols[j + 1] - cols[j])
#       row_sum += cell_area
#       prefix[i + 1][j + 1] = prefix[i][j + 1] + row_sum
#     end
#   end

#   prefix
# end

# def red_and_green_tiles(red_tile_coords)
#   red_and_green_tiles = Set.new
#   red_tile_coords.each_with_index do |coord_a, coord_a_index|
#     coord_b = red_tile_coords[(coord_a_index + 1) % red_tile_coords.length]
    
#     if coord_a.row == coord_b.row
#        # coord_b could be either higher or lower tha coord_a on either axis so,
#        # count in the correct direction from a to b
#       step = coord_a.col < coord_b.col ? 1 : -1
#       col = coord_a.col < coord_b.col ? coord_a.col + 1 : coord_a.col - 1
#       red_and_green_tiles.add([coord_a.row, coord_a.col])

#       while col != coord_b.col
#         red_and_green_tiles.add([coord_a.row, col])
#         col += step
#       end
#     elsif coord_a.col == coord_b.col
#       step = coord_a.row < coord_b.row ? 1 : -1
#       row = coord_a.row < coord_b.row ? coord_a.row + 1 : coord_a.row - 1
#       red_and_green_tiles.add([coord_a.row, coord_a.col])

#       while row != coord_b.row
#         red_and_green_tiles.add([row, coord_a.col])
#         row += step
#       end
#     end
#   end
#   red_and_green_tiles
# end

# def compress_2d(input)
#   coords_arr = create_coords(input)
#   map = Hash.new() 
#   rows = coords_arr.map(&:row)
#   cols = coords_arr.map(&:col).uniq
# end

# def fill_polygon_interior(red_and_green_tiles)
#   red_and_green_set = Set.new(red_and_green_tiles.map {|tile| [tile.row, tile.col] })
#   row_hash = red_and_green_tiles.group_by { |coord| coord.row }

#   row_hash.each do |row, tiles_in_row|
#     col_values = tiles_in_row.map(&:col)
#     min_col = col_values.min
#     max_col = col_values.max

#     ((min_col + 1)..(max_col - 1)).each do |col|
#       unless red_and_green_set.include?([row, col])
#         coord = Coord.new(row, col, 'green')
#         red_and_green_tiles << coord
#         red_and_green_set.add([row, col])
#       end
#     end
#   end
#   red_and_green_tiles.sort_by! { |tile| [tile.row, tile.col] }
# end

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
result = largest_filled_rect(TEST_DATA)
puts result === 24 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 2"
time = Benchmark.measure do
  result = largest_filled_rect(REAL_DATA)
end
puts 'time taken -> ', time
puts result === 1525991432 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)