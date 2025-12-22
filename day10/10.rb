require_relative "../utils"
require 'benchmark'

def split_data(input)
  input.map do |str|
    arr = str.split(' ')
    lights, *buttons, batteries = arr
    data = {
      lights: lights.gsub!(/[\[\]]/, ""),
      buttons: buttons.map { |button| button.delete!("()") },
      batteries: batteries.delete!("{}")
    }
    return data
  end
end


####################################
REAL_DATA = fetch_puzzle_input(10)
# col, row - 0 indexed
TEST_DATA = ['[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}']
# puts sort_by_row(TEST_DATA).each_cons(1) { |e| area(e[0], e[1]) }.inspect 
# puts largest_rect(TEST_DATA)
# puts largest_rect(TEST_DATA).each {|e| puts e.inspect }
# puts REAL_DATA.inspect
split_data(TEST_DATA) => { lights:, buttons:, batteries: }
puts lights.inspect
# puts "Running test 1"
# result = largest_rect(TEST_DATA)
# puts result === 50 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 1"
# result = largest_rect(REAL_DATA)
# puts result === 4748769124 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = largest_filled_rect(TEST_DATA)
# puts result === 24 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = largest_filled_rect(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 1525991432 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)