require_relative "../utils"
require 'benchmark'

def fresh_ids_and_ingredients(input)
  fresh_ids, ingredients = input.partition { |el| el.include?('-')}
  ingredients = ingredients.reject(&:empty?)

  fresh_id_ranges = fresh_ids.map do |str|
    match = str.match(/^(\d+)-(\d+)$/)
    Range.new(match[1].to_i, match[2].to_i)
  end

  ingredients = ingredients.map(&:to_i)
  return { fresh_ids: fresh_id_ranges, ingredients: ingredients }
end


def fresh_ingredient_count(input)
  processed_data = fresh_ids_and_ingredients(input)
  fresh_ids = processed_data[:fresh_ids]
  ingredients = processed_data[:ingredients]

  fresh_ingredient_count = 0

  ingredients.each do |ingredient|
    fresh_ids.each do |id_range|
      if id_range.include?(ingredient)
        fresh_ingredient_count += 1 
        break
      end
    end
  end

  fresh_ingredient_count
end

def fresh_ingredient_id_count(input)
  # fresh ids only
  fresh_ids = input.select { |el| el.include?('-') }

  # turn them into ranges
  fresh_id_ranges = fresh_ids.map do |str|
    match = str.match(/^(\d+)-(\d+)$/)
    Range.new(match[1].to_i, match[2].to_i)
  end

  merged_ranges = merge_ranges(fresh_id_ranges)
  
  merged_ranges.sum { |range| range.size }
end

def merge_ranges(ranges)
  sorted = ranges.sort_by(&:begin)
  merged = []

  sorted.each do |range|
    if merged.empty? || merged.last.end < range.begin - 1 # -1 because if they're consecutive we shoudl still merge them
      merged << range
    else
      merged[-1] = merged[-1].begin..[merged[-1].end, range.end].max
    end
  end
  merged
end


####################################
TEST_DATA = ["3-5", "10-14", "16-20", "12-18", "", "1", "5", "8", "11", "17", "32"]

REAL_DATA = fetch_puzzle_input(5)
# puts REAL_DATA.inspect
# puts fresh_ids_and_ingredients(REAL_DATA).inspect
# puts fresh_ids_and_ingredients(REAL_DATA)
# puts REAL_DATA.slice_before("\n\n").to_a
# puts REAL_DATA[0].split("\n\n")

puts "Running test 1"
result = fresh_ingredient_count(TEST_DATA)
puts result === 3 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = fresh_ingredient_count(REAL_DATA)
puts result === 601 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running test 2"
result = fresh_ingredient_id_count(TEST_DATA)
puts result === 14 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 2"
time = Benchmark.measure do
  result = fresh_ingredient_id_count(REAL_DATA)
end
puts 'time taken -> ', time
puts result === 367899984917516 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)