require_relative "../utils"
require 'benchmark'

def parse_data(input)
  devices = {}
  
  input.reject!(&:empty?)
  input.map do |device|
    match = device.match(/^([^:]+):\s*(.*)$/)
    devices[match[1]] = match[2].split(' ')
  end
  
  devices
end

def count_paths(input)
  data = parse_data(input)

  dfs = ->(self_fn, node) do 
    return 1 if node == "out"

    children = data[node] || []
    children.sum { |child| self_fn.call(self_fn, child) }
  end

  paths = dfs.call(dfs, "you")
  paths
end

def count_paths_2(input)
  data = parse_data(input)
  memo = {}

  dfs = ->(self_fn, node, fft=false, dac=false) do 
    fft ||= (node == 'fft')
    dac ||= (node == 'dac')
    
    return (fft && dac) ? 1 : 0 if node =="out"
    
    key = [node, fft, dac]
    return memo[key] if memo.key?(key)

    children = data[node] || []
    memo[key] = children.sum { |child| self_fn.call(self_fn, child, fft, dac) }
  end

  paths = dfs.call(dfs, "svr")
  paths
end




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
puts result == 18981 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)