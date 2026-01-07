require_relative "../utils"
require 'benchmark'


def parse_data(input)
  shapes = []
  regions = []
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

      shapes << { index => rows }
      next
    end

    if (match = el.match(/\A(\d{1,2})x(\d{1,2}):\s*([0-9 ]+)\z/))
      width, length = match[1].to_i, match[2].to_i
      present_counts = match[3].split(' ').map(&:to_i)
      regions << { 'width' => width, 'length' => length, 'present_counts' => present_counts }
    end
    
    i += 1
    next
  end
  
  return { 'shapes' => shapes, 'regions' => regions }
end

# approaches:
# eliminate if total area of presents > total region area
# auto accept if 3x3 * no of presents < total region area 
def valid_regions(input)
  shapes, regions = parse_data(input).values_at('shapes', 'regions')
  valid_count = 0

  regions.each do |region|
    region_vol = region['width'] * region['length']
    presents_vol = presents_volume(shapes, region['present_counts'])

    next if presents_vol > region_vol
    valid_count += 1 if (region['present_counts'].sum * 9) <= region_vol
    # now work out how to interleave - no need to pass part 1!
  end
  
  valid_count
end

def presents_volume(shapes, present_counts)
  volume = 0
  present_counts.each_with_index do |count, idx|
    volume += count * shape_volume(shapes[idx])
  end
  volume
end

def shape_volume(shape)
  unit_count = 0
  shape.each { |row| unit_count += row.count('#') }
  unit_count
end



####################################
REAL_DATA = fetch_cached_input(12)
TEST_DATA = ["0:", "###", "##.", "##.", "", "1:", "###", "##.", ".##", "", "2:", ".##", "###", "##.", "", "3:", "##.", "###", "##.", "", "4:", "###", "#..", "###", "", "5:", "###", ".#.", "###", "", "4x4: 0 0 0 0 2 0", "12x5: 1 0 1 0 2 2", "12x5: 1 0 1 0 3 2"]


# puts REAL_DATA.inspect
data = parse_data(REAL_DATA)
puts data['shapes']
puts data['regions']
# puts parse_data(REAL_DATA)[regions].inspect

puts "Running test 1"
result = valid_regions(TEST_DATA)
puts result === 2 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = valid_regions(REAL_DATA)
puts result === 476 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = count_paths_2(TEST_DATA2)
# puts result === 2 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = count_paths_2(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result == 315116216513280 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)