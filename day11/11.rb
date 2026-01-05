require_relative "../utils"
require 'benchmark'

def parse_data(input)
  devices = {}
  
  input.reject!(&:empty?).map do |device|
    match = device.match(/^([^:]+):\s*(.*)$/)
    devices[match[1]] = match[2].split(' ')
  end
  
  devices
end

def count_paths(input)
  data = parse_data(input)

  dfs = ->(self_fn, node) do 
    return 1 if node == "out"

    children = data[node] | []
    children.sum { |child| self_fn.call(self_fn, child) }
  end

  paths = dfs.call(dfs, "you")
  paths
end



####################################
REAL_DATA = fetch_puzzle_input(11)
TEST_DATA = ['aaa: you hhh', 'you: bbb ccc', 'bbb: ddd eee', 'ccc: ddd eee fff', 'ddd: ggg', 'eee: out', 'fff: out', 'ggg: out', 'hhh: ccc fff iii', 'iii: out', '']

# puts REAL_DATA.inspect
puts count_paths(REAL_DATA).inspect
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