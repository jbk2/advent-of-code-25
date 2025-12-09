require_relative "../utils"
require 'benchmark'

def is_splitter?(char)
  char === "^"
end

def split_counter(input)
  input.reject!(&:empty?)
  rows = input.map { _1.chars }
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

# index of s > index in next row have '.' or '^'

####################################

TEST_DATA = [".......S.......", "...............", ".......^.......", "...............", "......^.^......", "...............", ".....^.^.^.....", "...............", "....^.^...^....", "...............", "...^.^...^.^...", "...............", "..^...^.....^..", "...............", ".^.^.^.^.^...^.", "..............."]
REAL_DATA = fetch_puzzle_input(7)
# puts TEST_DATA.all? {_1.length == TEST_DATA[0].length }
# split_counter(TEST_DATA).each { |row| puts row.inspect }
# puts split_counter(TEST_DATA)


puts "Running test 1"
result = split_counter(TEST_DATA)
puts result === 21 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = split_counter(REAL_DATA)
puts result === 5877594983578 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = calculate_pt_two(TEST_DATA)
# puts result === 3263827 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = calculate_pt_two(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 11159825706149 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)