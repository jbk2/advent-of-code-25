require_relative "../utils"

####################################
def number_of_zeros_at_end(start_position, input)
  if !input.is_a?(Array) 
    puts('input was not an array')
    return
  end

  current_position = start_position
  no_of_zero_positions = 0

  input.each do |rotation|
    direction = rotation[0]
    number = rotation[1..-1].to_i

    new_position = direction == "R" ? current_position + number : current_position - number
    
    new_position = new_position % 100

    no_of_zero_positions += 1 if new_position == 0
    current_position = new_position
  end

  no_of_zero_positions
end

def total_clicks_on_zero(start_position, input)
  if !input.is_a?(Array) 
    puts('input was not an array')
    return
  end

  current_position = start_position
  no_of_zero_clicks = 0

  input.each do |rotation|
    direction = rotation[0]
    number_of_clicks = rotation[1..-1].to_i
    dist_to_zero = direction == "R" ? (100 - current_position) % 100 : current_position
    
    # we were already at zero so don't count it till we hit it again 
    dist_to_zero = 100 if dist_to_zero == 0
    
    if number_of_clicks >= dist_to_zero
      no_of_zero_clicks += 1 + (number_of_clicks - dist_to_zero) / 100
    end
    
    current_position =
      direction == "R" ?
        (current_position + number_of_clicks) % 100 :
        (current_position - number_of_clicks) % 100
  end

  no_of_zero_clicks
end


MINI_TEST_DATA = ["L68", "L30", "R48", "L5", "R60", "L55", "L1", "L99", "R14", "L82"]
REAL_DATA = fetch_puzzle_input(1)

puts "Running mini test 1"
result = number_of_zeros_at_end(50, MINI_TEST_DATA)
puts result === 3 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real test 1"
result = number_of_zeros_at_end(50, REAL_DATA)
puts result === 1177 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# MINI TEST
puts "Running mini test 2"
result = total_clicks_on_zero(50, MINI_TEST_DATA)
puts result === 6 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# REAL TEST
puts "Running real test 2"
result = total_clicks_on_zero(50, REAL_DATA)
puts result === 6768 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)
