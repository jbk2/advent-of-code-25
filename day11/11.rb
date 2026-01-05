require_relative "../utils"
require 'benchmark'

def parse_data(input)
  sorted_data = input.reject!(&:empty?).map do |device|
    match = device.match(/^([^:]+):\s*(.*)$/)
    { match[1] => match[2].split(' ') }
  end
  sorted_data
end

####################################
REAL_DATA = fetch_puzzle_input(11)
TEST_DATA = ['aaa: you hhh', 'you: bbb ccc', 'bbb: ddd eee', 'ccc: ddd eee fff', 'ddd: ggg', 'eee: out', 'fff: out', 'ggg: out', 'hhh: ccc fff iii', 'iii: out', '']

# puts REAL_DATA.inspect
puts parse_data(TEST_DATA).inspect
# puts parse_data(REAL_DATA).inspect

# puts "Running test 1"
# result = total_combos(TEST_DATA)
# puts result === 7 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 1"
# result = total_combos(REAL_DATA)
# puts result === 507 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = counts_to_joltage(TEST_DATA)
# puts result === 33 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = counts_to_joltage(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result == 18981 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)