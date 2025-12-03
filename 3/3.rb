require_relative "../utils"
require 'benchmark'

# each line = a bank, each number = a battery's joltage
# can take two batteries from a bank
# find max joltage per bank
# total output = sum of max joltage from each bank

def max_joltage(input)
  bank_maximums = []

  input.each do |bank|
    bank_digits = bank.chars.map(&:to_i)
    max_val = 0

    bank_digits.each_with_index do |first_battery, index|
      remainder = bank_digits[index + 1..-1]
      next if remainder.empty?      
      
      best_second_battery = bank_digits[(index + 1)..-1].max
      max_val = [first_battery * 10 + best_second_battery, max_val].max
      # binding.irb
    end

    bank_maximums << max_val
  end
  bank_maximums.reduce(:+)
end



####################################
TEST_DATA = ["987654321111111","811111111111119","234234234234278","818181911112111"]
REAL_DATA = fetch_puzzle_input(3)

puts "Running test 1"
result = max_joltage(TEST_DATA)
puts result === 357 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = max_joltage(REAL_DATA)
puts result === 17427 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = invalid_ids_sum_three(TEST_DATA)
# puts result === 4174379265 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = invalid_ids_sum_three(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 30962646823 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)