require_relative "../utils"
require 'benchmark'
require 'debug'

def split_data(input)
  input.reject!(&:empty?)
  parsed_input = input.map do |str|
    arr = str.split(' ')
    lights, *buttons, batteries = arr
    
    lights = lights.gsub!(/[\[\]]/, "").split('').map { |el| el == '#' ? 1 : 0 }
    lights_count = lights.length
    
    buttons.map! do |button|        
      btn_arr = button.delete!("()").split(',').map(&:to_i)
      btn_bitmask(lights_count, btn_arr)
    end
  
    batteries = batteries.delete!("{}").split(',').map(&:to_i)
  
    { lights: lights, buttons: buttons, batteries: batteries }
  end
end

def btn_bitmask(length, btn_arr)
  mask = Array.new(length, 0)
  btn_arr.each { |i| mask[i] = 1 }
  return mask
end

def total_combos(input)
  data = split_data(input)
  total_btn_presses = []
  
  data.each do |machine|
    lights, buttons = machine.values_at(:lights, :buttons)
    no_of_lights = lights.length
    btn_count = buttons.length
    found = false
    
    (1..btn_count).each do |combo_count|
      buttons.combination(combo_count) do |combinations|
        mask = Array.new(no_of_lights, 0)

        combinations.each do |btn|
          btn.each_with_index do |light, idx|
            mask[idx] = mask[idx] ^ light            
          end
        end
          
        if lights == mask
          total_btn_presses << combo_count
          found = true
          break
        end
      end
      break if found
    end
  end
  total_btn_presses.sum
end

def counts_to_joltage(input)
  data = split_data(input)
  fewest_presses = []

  data.each do |machine|
    buttons, batteries = machine.values_at(:buttons, :batteries)
    remaining_joltage = batteries.dup

    fewest_presses << search_joltage(buttons, remaining_joltage, 0, Float::INFINITY)
    
  end

  fewest_presses.sum
end

def search_joltage(buttons, remaining_joltage, press_count, least_count)
  return least_count if press_count >= least_count
  return press_count if remaining_joltage.all?(0)
  return least_count if press_count + min_remaining_presses(remaining_joltage) >= least_count

  buttons = remove_unviable_buttons(buttons.dup, remaining_joltage)
  return least_count if buttons.empty?

  button = buttons.first
  max_times = remaining_joltage.each_index.select { |i| button[i] == 1 }.map { |i| remaining_joltage[i] }.min

  max_times.downto(0) do |times|
    new_remaining_joltage = press_btn_times(remaining_joltage, button, times)
    next unless new_remaining_joltage
     new_buttons = buttons.dup
     new_buttons.delete(button)

     least_count = [least_count, search_joltage(new_buttons, new_remaining_joltage, press_count + times, least_count)].min
  end

  least_count
end

def remove_unviable_buttons(buttons, remaining)
  remaining.each_with_index do |joltage, idx|
    if joltage < 1
      buttons.reject! { |bat| bat[idx] == 1 }
    end
  end
  buttons
end

def press_btn_times(remaining, button, times)
  return remaining if times < 1
  updated_remaining = remaining.dup

  button.each_with_index do |battery, idx|
    next unless battery == 1
    updated_remaining[idx] -= times
    return false if updated_remaining[idx] < 0
  end

  updated_remaining
end

def min_remaining_presses(remaining)
  remaining.max
end

####################################
REAL_DATA = fetch_puzzle_input(10)
TEST_DATA = ['[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}', '[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}', '[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}']

puts counts_to_joltage(TEST_DATA)

puts "Running test 1"
result = total_combos(TEST_DATA)
puts result === 7 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = total_combos(REAL_DATA)
puts result === 507 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running test 2"
result = counts_to_joltage(TEST_DATA)
puts result === 33 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 2"
time = Benchmark.measure do
  result = counts_to_joltage(REAL_DATA)
end
puts 'time taken -> ', time
puts result === 1525991432 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)