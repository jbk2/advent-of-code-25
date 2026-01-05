require_relative "../utils"
require 'benchmark'




####################################
REAL_DATA = fetch_puzzle_input(11)
TEST_DATA1 = ['aaa: you hhh', 'you: bbb ccc', 'bbb: ddd eee', 'ccc: ddd eee fff', 'ddd: ggg', 'eee: out', 'fff: out', 'ggg: out', 'hhh: ccc fff iii', 'iii: out', '']
TEST_DATA2 = ['svr: aaa bbb', 'aaa: fft', 'fft: ccc', 'bbb: tty', 'tty: ccc', 'ccc: ddd eee', 'ddd: hub', 'hub: fff', 'eee: dac', 'dac: fff', 'fff: ggg hhh', 'ggg: out', 'hhh: out', '']

# puts REAL_DATA.inspect
puts count_paths_2(TEST_DATA2).inspect
# puts parse_data(REAL_DATA).inspect

puts "Running test 1"
result = count_paths(TEST_DATA1)
puts result === 5 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = count_paths(REAL_DATA)
puts result === 508 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running test 2"
result = count_paths_2(TEST_DATA2)
puts result === 2 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 2"
time = Benchmark.measure do
  result = count_paths_2(REAL_DATA)
end
puts 'time taken -> ', time
puts result == 315116216513280 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)