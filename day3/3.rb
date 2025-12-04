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
    end

    bank_maximums << max_val
  end
  bank_maximums.reduce(:+)
end

def max_joltage_twelve(input)
  highest_bank_joltages = []

  input.each do |bank|
    selected_batteries = []
    no_of_picks = 12
    bank_length = bank.length
    earliest_pic_index = 0
    
    no_of_picks.times do |picks_index|
      no_of_picks_remaining = no_of_picks - (picks_index + 1)
      latest_pick_index = (bank_length - 1) - no_of_picks_remaining
      pick_option_indexes = (earliest_pic_index..latest_pick_index)

      highest_val_index = pick_option_indexes.max_by { |index| bank[index] }
      
      selected_batteries << bank[highest_val_index]
      earliest_pic_index = highest_val_index + 1
    end

    highest_bank_joltages << selected_batteries.join.to_i
  end
  highest_bank_joltages.reduce(:+)
end



####################################
TEST_DATA = ["987654321111111","811111111111119","234234234234278","818181911112111"]
REAL_DATA = fetch_puzzle_input(3)

# puts REAL_DATA

puts "Running test 1"
result = max_joltage(TEST_DATA)
puts result === 357 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = max_joltage(REAL_DATA)
puts result === 17427 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running test 2"
result = max_joltage_twelve(TEST_DATA)
puts result === 3121910778619 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 2"
time = Benchmark.measure do
  result = max_joltage_twelve(REAL_DATA)
end
puts 'time taken -> ', time
puts result === 173161749617495 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)