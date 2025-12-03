require_relative "../utils"

def convert_to_arr_of_ranges(input)
  arr = input.is_a?(String) ? input.split(',') : input[0].split(',')
  arr.map do |el|
    start, finish = el.split('-').map(&:to_i)
    Range.new(start, finish)
  end  
end

def invalid_ids_sum(input)
  ranges = convert_to_arr_of_ranges(input)
  invalid_ids = []
  
  ranges.each do |range|
    ids_arr = range.to_a
    
    ids_arr.each do |id|
      id_string = id.to_s
      no_of_id_digits = id_string.length
      
      if no_of_id_digits % 2 == 0
        end_first_half_index = (no_of_id_digits / 2) - 1
        first_half = id_string.slice(0..end_first_half_index)
        second_half = id_string.slice(end_first_half_index + 1..-1)
        invalid_ids << id if first_half == second_half
      end
    end
    
  end
  
  invalid_ids.reduce(:+)
end


# 'ID is invalid if some sequence of digits repeated at least twice'
# - i.e. check sublengths iteratively all the way from
# n = length/2 counting down to 1, if length % n == 0
def invalid_ids_sum_two(input)
  ranges = convert_to_arr_of_ranges(input)
  invalid_ids = []
  divisors = []

  ranges.each do |range|
    ids_arr = range.to_a

    ids_arr.each do |id|
      id_string = id.to_s
      id_length = id_string.length

      divisors = (1..(id_length / 2)).filter {|n| id_length % n == 0 }
      is_invalid = false

      divisors.each do |divisor|
        arr = id_string.scan(/.{#{divisor}}/)
        if arr.uniq.length == 1
          is_invalid = true
          break
        end
      end

      invalid_ids << id if is_invalid
    end
  end
  
  invalid_ids.reduce(:+)
end



####################################
TEST_DATA = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
REAL_DATA = fetch_puzzle_input(2)

puts "Running test 1"
result = invalid_ids_sum(TEST_DATA)
puts result === 1227775554 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = invalid_ids_sum(REAL_DATA)
puts result === 24747430309 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# MINI TEST
puts "Running test 2"
result = invalid_ids_sum_two(TEST_DATA)
puts result === 4174379265 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# REAL TEST
puts "Running real data test 2"
result = invalid_ids_sum_two(REAL_DATA)
puts result === 30962646823 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)