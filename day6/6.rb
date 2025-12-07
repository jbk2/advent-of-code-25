require_relative "../utils"
require 'benchmark'

def parse_to_arrays(input)
  input.map { |str| str.split(' ') }
end

def calculate(input)
  array = parse_to_arrays(input)
  array.all? {|inner_arr| inner_arr.length == array[0].length }

end



####################################
TEST_DATA = ["123", "", "328", "", "51", "", "64", "", "45", "", "64", "", "387", "", "23", "", "6", "", "98" ,"", "215", "", "314", "", "*", "", "+", "", "*", "", "+",]
TEST_DATA = ["123 328 51 64", "45 64 387 23", "6 98 215 314", "* + * +"]

puts calculate(TEST_DATA)


# puts "Running test 1"
# result = fresh_ingredient_count(TEST_DATA)
# puts result === 3 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 1"
# result = fresh_ingredient_count(REAL_DATA)
# puts result === 601 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = fresh_ingredient_id_count(TEST_DATA)
# puts result === 14 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = fresh_ingredient_id_count(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 367899984917516 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)