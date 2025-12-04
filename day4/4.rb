require_relative "../utils"
require 'benchmark'


def accessible_rolls(input)
  position_checks = [[0, -1], [1, -1],  [1, 0],  [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1]]
  accessible_roll_count = 0
  adjusted_input = input.map(&:dup)
  
  input.each_with_index do |row, row_index|
    row.split('').each_with_index do |char, col_index|
      next unless char == '@'
      adjacency_count = 0
      
      position_checks.each do |position|
        row_to_check = row_index + position[0]
        col_to_check = col_index + position[1]

        next if row_to_check < 0 || row_to_check >= input.length
        next if col_to_check < 0 || col_to_check >= input[row_to_check].length

        if input[row_to_check][col_to_check] == '@'
          adjacency_count += 1 
        end
      end

      if adjacency_count < 4
        adjusted_input[row_index][col_index] = 'x'
        accessible_roll_count += 1
      end
    end
  end

  accessible_roll_count
end





####################################
TEST_DATA = ["..@@.@@@@.", "@@@.@.@.@@", "@@@@@.@.@@", "@.@@@@..@.", "@@.@@@@.@@", ".@@@@@@@.@", ".@.@.@.@@@", "@.@@@.@@@@", ".@@@@@@@@.", "@.@.@@@.@."]
REAL_DATA = fetch_puzzle_input(4)

# puts REAL_DATA.all? { |e| e.length == 136 }
# puts accessible_rolls(TEST_DATA)

puts "Running test 1"
result = accessible_rolls(TEST_DATA)
puts result === 13 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = accessible_rolls(REAL_DATA)
puts result === 17427 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = max_joltage_twelve(TEST_DATA)
# puts result === 3121910778619 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = max_joltage_twelve(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 173161749617495 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)