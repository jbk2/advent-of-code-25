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

  input = adjusted_input
  return { updated_input: input, removed: accessible_roll_count }
end


def total_accessible_rolls(input, roll_counter = 0)
  roll_removal_operation_object = accessible_rolls(input)
  removed_rolls = roll_removal_operation_object[:removed]
  updated_list = roll_removal_operation_object[:updated_input]


  return roll_counter if removed_rolls == 0

  roll_counter += removed_rolls
  # puts("roll counter is; #{roll_counter}", "removed rolls last iteration were; #{removed_rolls}")
  total_accessible_rolls(updated_list, roll_counter)
end




####################################
TEST_DATA = ["..@@.@@@@.", "@@@.@.@.@@", "@@@@@.@.@@", "@.@@@@..@.", "@@.@@@@.@@", ".@@@@@@@.@", ".@.@.@.@@@", "@.@@@.@@@@", ".@@@@@@@@.", "@.@.@@@.@."]
REAL_DATA = fetch_puzzle_input(4)

# puts REAL_DATA.all? { |e| e.length == 136 }
# puts accessible_rolls(TEST_DATA)

puts "Running test 1"
result = accessible_rolls(TEST_DATA)[:removed]
puts result === 13 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = accessible_rolls(REAL_DATA)[:removed]
puts result === 1433 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
result = total_accessible_rolls(TEST_DATA)
puts result === 43 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 2"
time = Benchmark.measure do
  result = total_accessible_rolls(REAL_DATA)
end
puts 'time taken -> ', time
puts result === 8616 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)