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

  r_idx, c_idx, prefix = build_valid_area_prefix(red_tiles)

  max_area = 0
  red_tiles.each_with_index do |a, i|
    red_tiles.each_with_index do |b, j|
      next if i >= j

      min_row, max_row = [a.row, b.row].minmax
      min_col, max_col = [a.col, b.col].minmax

      rect_area = (max_row - min_row + 1) * (max_col - min_col + 1)
      next if rect_area <= max_area

      # Rectangle covers [min_row, max_row+1) x [min_col, max_col+1)
      r0 = r_idx[min_row]
      r1 = r_idx[max_row + 1]
      c0 = c_idx[min_col]
      c1 = c_idx[max_col + 1]

      valid_area = prefix[r1][c1] - prefix[r0][c1] - prefix[r1][c0] + prefix[r0][c0]
      max_area = rect_area if valid_area == rect_area
    end
  end

  max_area
end

def build_valid_area_prefix(red_tiles)
  rows, cols, r_idx, c_idx = build_compressed_axes(red_tiles)
  wall = build_wall_grid(red_tiles, rows, cols, r_idx, c_idx)
  outside = flood_fill_outside(wall)
  prefix = build_valid_area_prefix_sum(outside, rows, cols)
  [r_idx, c_idx, prefix]
end

def build_compressed_axes(red_tiles)
  # each tile is a square with edges going from [row,row+1) x [col,col+1)
  min_row, max_row = red_tiles.map(&:row).minmax
  min_col, max_col = red_tiles.map(&:col).minmax

  row_vals = Set.new([min_row - 1, max_row + 2])
  col_vals = Set.new([min_col - 1, max_col + 2])

  red_tiles.each do |t|
    # Add neighbors so corner contacts don't create leaks.
    [t.row - 1, t.row, t.row + 1, t.row + 2].each { row_vals.add(_1) }
    [t.col - 1, t.col, t.col + 1, t.col + 2].each { col_vals.add(_1) }
  end

  rows = row_vals.to_a.sort
  cols = col_vals.to_a.sort

  r_idx = {}
  rows.each_with_index { |v, i| r_idx[v] = i }
  c_idx = {}
  cols.each_with_index { |v, i| c_idx[v] = i }

  [rows, cols, r_idx, c_idx]
end

def build_wall_grid(red_tiles, rows, cols, r_idx, c_idx)
  h = rows.length - 1
  w = cols.length - 1
  wall = Array.new(h) { Array.new(w, false) }

  # Draw boundary tiles for each axis-aligned segment.
  red_tiles.each_with_index do |a, i|
    b = red_tiles[(i + 1) % red_tiles.length]

    if a.row == b.row
      r = r_idx[a.row]
      c0, c1 = [a.col, b.col].minmax
      start = c_idx[c0]
      finish = c_idx[c1 + 1] - 1
      (start..finish).each { |cj| wall[r][cj] = true }
    else
      c = c_idx[a.col]
      r0, r1 = [a.row, b.row].minmax
      start = r_idx[r0]
      finish = r_idx[r1 + 1] - 1
      (start..finish).each { |ri| wall[ri][c] = true }
    end
  end

  wall
end

def flood_fill_outside(wall)
  h = wall.length
  w = wall[0].length
  outside = Array.new(h) { Array.new(w, false) }

  # Start from the padded top-left cell (guaranteed outside).
  stack = [[0, 0]]
  outside[0][0] = true

  until stack.empty?
    r, c = stack.pop
    [[r - 1, c], [r + 1, c], [r, c - 1], [r, c + 1]].each do |nr, nc|
      next if nr < 0 || nr >= h || nc < 0 || nc >= w
      next if outside[nr][nc]
      next if wall[nr][nc]
      outside[nr][nc] = true
      stack << [nr, nc]
    end
  end

  outside
end

def build_valid_area_prefix_sum(outside, rows, cols)
  h = outside.length
  w = outside[0].length
  prefix = Array.new(h + 1) { Array.new(w + 1, 0) }

  (0...h).each do |i|
    row_sum = 0
    (0...w).each do |j|
      cell_area = outside[i][j] ? 0 : (rows[i + 1] - rows[i]) * (cols[j + 1] - cols[j])
      row_sum += cell_area
      prefix[i + 1][j + 1] = prefix[i][j + 1] + row_sum
    end
  end

  prefix
end

def red_and_green_tiles(red_tile_coords)
  red_and_green_tiles = Set.new
  red_tile_coords.each_with_index do |coord_a, coord_a_index|
    coord_b = red_tile_coords[(coord_a_index + 1) % red_tile_coords.length]
    
    if coord_a.row == coord_b.row
       # coord_b could be either higher or lower tha coord_a on either axis so,
       # count in the correct direction from a to b
      step = coord_a.col < coord_b.col ? 1 : -1
      col = coord_a.col < coord_b.col ? coord_a.col + 1 : coord_a.col - 1
      red_and_green_tiles.add([coord_a.row, coord_a.col])

      while col != coord_b.col
        red_and_green_tiles.add([coord_a.row, col])
        col += step
      end
    elsif coord_a.col == coord_b.col
      step = coord_a.row < coord_b.row ? 1 : -1
      row = coord_a.row < coord_b.row ? coord_a.row + 1 : coord_a.row - 1
      red_and_green_tiles.add([coord_a.row, coord_a.col])

      while row != coord_b.row
        red_and_green_tiles.add([row, coord_a.col])
        row += step
      end
    end
  end
  red_and_green_tiles
end

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