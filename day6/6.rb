require_relative "../utils"
require 'benchmark'

def parse_to_arrays(input)
  cleaned_input = input.map { |str| str.strip.split(/\s+/)}
  cleaned_input.reject(&:empty?)
end

def calculate(input)
  sum_of_sums = 0
  rows = parse_to_arrays(input)
  operators = rows.delete_at(-1)

  operators.each_with_index do |operator, index|
    calc = []

    rows.each do |row|
      calc << row[index].to_i
    end

    sum_of_sums += calc.reduce do |acc, no|
        acc.send(operator.to_sym, no) 
    end
  end
  
  sum_of_sums
end


def clean_data(input)
  rows = input.reject(&:empty?)
  rows_same_length = rows.all? { |row| row.length == rows[0].length }
  return "rows not all same length" unless rows_same_length
  rows
end

def calculate_reverse_sum(input)
  rows = clean_data(input)
  no_of_rows = rows.count
  no_of_digits = rows[0].length
  
  number_length = no_of_rows - 1
  calculations_array = []
  calculation = { operator: "", numbers: "" }
  digit_index = no_of_digits - 1
  
  no_of_digits.times do
    calc_end_tracker = (0...no_of_rows).to_h { |i| [i, nil] }
    
    rows.each_with_index do |row, row_index|

      char = row[digit_index]
      is_operator_row = true if row_index + 1 == number_length + 1
      
      calc_end_tracker[row_index] = char == " "
      
      if is_operator_row
        calculation[:operator] << char if char.match(/[+*]/)
        calculation[:numbers] << ","
      else
        calculation[:numbers] << char
      end
    end
    
    if calc_end_tracker.values.all? { |value| value === true }
      calculations_array << calculation
      calculation = { operator: "", numbers: "" }
    end

    digit_index -= 1
  end
  calculations_array << calculation if digit_index < 0 
  calculations_array
  sum_calc(calculations_array)
end

def sum_calc(calcs_array)
  sum = 0
  calcs_array.each do |calc|
    operator = calc[:operator].to_sym
    nos_arr = calc[:numbers].split(',').map(&:strip).reject(&:empty?).map(&:to_i)
  
    sum += nos_arr.reduce { |acc, el| acc.send(operator, el) }
  end

  sum
end

####################################

TEST_DATA = ["123 328  51 64 ", " 45 64  387 23 ", "  6 98  215 314", "*   +   *   +  "]
# 123 328  51 64 
#  45 64  387 23 
#   6 98  215 314
# *   +   *   +  

REAL_DATA = fetch_puzzle_input(6)

puts clean_data(TEST_DATA).inspect
puts calculate_reverse_sum(TEST_DATA).inspect


puts "Running test 1"
result = calculate(TEST_DATA)
puts result === 4277556 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = calculate(REAL_DATA)
puts result === 5877594983578 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running test 2"
result = calculate_reverse_sum(TEST_DATA)
puts result === 3263827 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 2"
time = Benchmark.measure do
  result = calculate_reverse_sum(REAL_DATA)
end
puts 'time taken -> ', time
puts result === 367899984917516 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)