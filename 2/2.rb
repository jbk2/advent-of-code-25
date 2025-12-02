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




####################################
MINI_TEST_DATA = "11-22, 95-115, 998-1012, 1188511880-1188511890, 222220-222224, 1698522-1698528, 446443-446449, 38593856-38593862"
REAL_DATA = fetch_puzzle_input(2)
# puts invalid_ids_sum(MINI_TEST_DATA)
# puts convert_to_arr_of_ranges(REAL_DATA)
puts invalid_ids_sum(REAL_DATA)


# puts "Running mini test 1"
# result = number_of_zeros_at_end(50, MINI_TEST_DATA)
# puts result === 3 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real test 1"
# result = number_of_zeros_at_end(50, REAL_DATA)
# puts result === 1177 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# # MINI TEST
# puts "Running mini test 2"
# result = total_clicks_on_zero(50, MINI_TEST_DATA)
# puts result === 6 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# # REAL TEST
# puts "Running real test 2"
# result = total_clicks_on_zero(50, REAL_DATA)
# puts result === 6768 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)