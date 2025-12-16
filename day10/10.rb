require_relative "../utils"
require 'benchmark'

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