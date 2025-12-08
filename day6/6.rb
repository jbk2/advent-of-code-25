require_relative "../utils"
require 'benchmark'

def parse_to_arrays(input)
  cleaned_input = input.map { |str| str.strip.split(/\s+/)}
  cleaned_input.reject(&:empty?)
end

def calculate(input)
  sum_of_sums = 0
  rows = parse_to_arrays(input)
  operators = rows.delete_at(-1)

  operators.each_with_index do |operator, index|
    calc = []

    rows.each do |row|
      calc << row[index].to_i
    end

    sum_of_sums += calc.reduce do |acc, no|
        acc.send(operator.to_sym, no) 
    end
  end
  
  sum_of_sums
end

def calc_right_to_left(input)
  
end

####################################

TEST_DATA = ["  123 328  51 64", "45 64 387 23", "6 98 215 314", "* + * +"]
REAL_DATA = fetch_puzzle_input(6)


puts "Running test 1"
result = calculate(TEST_DATA)
puts result === 4277556 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = calculate(REAL_DATA)
puts result === 5877594983578 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = fresh_ingredient_id_count(TEST_DATA)
# puts result === 14 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = fresh_ingredient_id_count(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 367899984917516 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)