require_relative "../utils"
require 'benchmark'

def is_splitter?(char)
  char === "^"
end

def parse_to_2d_arrays(input)
  input.reject(&:empty?)
  rows = input.map { _1.chars }
end

def split_counter(input)
  rows = parse_to_2d_arrays(input)
  split_count = 0
  beam_indexes = []

  rows.map.with_index do |row, index|
    if index == 0
      beam_indexes << row.find_index('S')
    else
      beam_indexes.each do |beam_idx|
        if is_splitter?(row[beam_idx])
          split_count += 1
          row[beam_idx - 1] = "|"
          row[beam_idx + 1] = "|"
        else
          row[beam_idx] = "|"
        end
      end
    
      beam_indexes = []
      row.each_with_index { |el, el_index| beam_indexes << el_index if el == "|" }
    end
  end

  split_count
end

def dfs(row_idx, col_idx, rows, memo)
  $call_count += 1
  cache_key = [row_idx, col_idx]

  return memo[cache_key] if memo.key?(cache_key)

  if row_idx + 1 == rows.length
    memo[cache_key] = 1
    return 1
  end
  
  next_row_idx = row_idx + 1
  next_char = rows[next_row_idx][col_idx]
  
  if next_char == "^"
    left_paths = dfs(next_row_idx, col_idx - 1, rows, memo)
    right_paths = dfs(next_row_idx, col_idx + 1, rows, memo)
    result = left_paths + right_paths
  else
    result =  dfs(next_row_idx, col_idx, rows, memo)
  end
  memo[cache_key] = result
  return result
end
  
def path_count(input)
  $call_count = 0
  memo = {}
  rows = parse_to_2d_arrays(input)
  start_col = rows[0].find_index('S')
  start_coord = { row: 0, col: start_col }
  result = dfs(start_coord[:row], start_coord[:col], rows, memo) 
  puts "total recursive calls = #{$call_count}"
  result
end

####################################

TEST_DATA = [".......S.......", "...............", ".......^.......", "...............", "......^.^......", "...............", ".....^.^.^.....", "...............", "....^.^...^....", "...............", "...^.^...^.^...", "...............", "..^...^.....^..", "...............", ".^.^.^.^.^...^.", "..............."]
REAL_DATA = fetch_puzzle_input(7)

puts "Running test 1"
result = split_counter(TEST_DATA)
puts result === 21 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = split_counter(REAL_DATA)
puts result === 1537 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running test 2"
result = path_count(TEST_DATA)
puts result === 40 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 2"
time = Benchmark.measure do
  result = path_count(REAL_DATA)
end
puts 'time taken -> ', time
puts result === 18818811755665 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)