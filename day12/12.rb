require_relative "../utils"
require 'benchmark'


def parse_data(input)
  present_dimensions = []
  tree_dimensions = []

  i = 0 

  while i < input.length
    el = input[i]

    if el.empty?
      i += 1
      next
    end

    if (present_index = el.match(/(\A\d:)/))
      index = el.match(/\d+/)[0].to_i
      rows = []

      i += 1
      
      while i < input.length && !input[i].empty? && !input[i].match?(/\A\d{1,2}x\d{1,2}/) && input[i].match?(/\A[#.]+\z/)
        rows << input[i]
        i += 1
      end

      present_dimensions << { index => rows }
      next
    end

    if (match = el.match(/\A(\d{1,2})x(\d{1,2}):\s*([0-9 ]+)\z/))
      width, length = match[0].to_i, match[1].to_i
      present_counts = match[3].split(' ').map(&:to_i)
      tree_dimensions << { 'width' => width, 'length' => length, 'present_counts' => present_counts }
    end
    
    i += 1
    next
  end
  
  return { 'tree_dimensions' => tree_dimensions, 'present_dimensions' => present_dimensions }
  
end


####################################
REAL_DATA = fetch_puzzle_input(12)
TEST_DATA = ["0:", "###", "##.", "##.", "", "1:", "###", "##.", ".##", "", "2:", ".##", "###", "##.", "", "3:", "##.", "###", "##.", "", "4:", "###", "#..", "###", "", "5:", "###", ".#.", "###", "", "4x4: 0 0 0 0 2 0", "12x5: 1 0 1 0 2 2", "12x5: 1 0 1 0 3 2"]


# puts REAL_DATA.inspect
puts parse_data(TEST_DATA).inspect

# puts "Running test 1"
# result = count_paths(TEST_DATA1)
# puts result === 5 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 1"
# result = count_paths(REAL_DATA)
# puts result === 508 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = count_paths_2(TEST_DATA2)
# puts result === 2 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = count_paths_2(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result == 315116216513280 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)