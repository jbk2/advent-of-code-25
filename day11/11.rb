
####################################
REAL_DATA = fetch_puzzle_input(11)
TEST_DATA = ['']

puts counts_to_joltage(TEST_DATA)

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