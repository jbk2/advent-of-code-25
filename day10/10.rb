require_relative "../utils"
require 'benchmark'

def split_data(input)
  input.reject!(&:empty?)
  input.map do |line|
    parts = line.split(' ')
    lights_token, *button_tokens, batteries_token = parts

    lights = lights_token.delete('[]').chars.map { |ch| ch == '#' ? 1 : 0 }
    batteries = batteries_token.delete('{}').split(',').map(&:to_i)

    # Keep raw button index lists so we can build masks of different lengths (lights vs batteries).
    button_index_lists = button_tokens.map do |tok|
      tok.delete('()').split(',').map(&:to_i)
    end

    light_buttons = button_index_lists.map { |idxs| btn_bitmask(lights.length, idxs) }
    joltage_buttons = button_index_lists.map { |idxs| btn_bitmask(batteries.length, idxs) }

    { lights: lights, light_buttons: light_buttons, joltage_buttons: joltage_buttons, batteries: batteries }
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
    lights, buttons = machine.values_at(:lights, :light_buttons)
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
  split_data(input).sum do |machine|
    buttons, batteries = machine.values_at(:joltage_buttons, :batteries)
    min_presses_for_joltage_machine(buttons, batteries)
  end
end

# --- Part 2: fast exact solver (elimination + small enumeration) ---

def gauss_jordan_rref(augmented_rows)
  row_count = augmented_rows.length
  col_count = augmented_rows[0].length # includes RHS
  var_count = col_count - 1

  pivot_cols = []
  pivot_row = 0

  (0...var_count).each do |col|
    row_with_pivot = (pivot_row...row_count).find { |r| augmented_rows[r][col] != 0 }
    next unless row_with_pivot

    augmented_rows[pivot_row], augmented_rows[row_with_pivot] = augmented_rows[row_with_pivot], augmented_rows[pivot_row]

    pivot_val = augmented_rows[pivot_row][col]
    augmented_rows[pivot_row].map! { |x| x / pivot_val }

    (0...row_count).each do |r|
      next if r == pivot_row
      factor = augmented_rows[r][col]
      next if factor == 0
      col_count.times { |k| augmented_rows[r][k] -= factor * augmented_rows[pivot_row][k] }
    end

    pivot_cols << col
    pivot_row += 1
    break if pivot_row == row_count
  end

  [augmented_rows, pivot_cols]
end

def min_presses_for_joltage_machine(button_masks, targets)
  counter_count = targets.length
  button_count = button_masks.length

  augmented = Array.new(counter_count) do |counter_idx|
    coeffs = Array.new(button_count) { |button_idx| button_masks[button_idx][counter_idx] }
    coeffs.map { |v| Rational(v, 1) } + [Rational(targets[counter_idx], 1)]
  end

  rref, pivot_cols = gauss_jordan_rref(augmented)

  # Inconsistent system? (0 = non-zero)
  rref.each do |row|
    left = row[0...button_count]
    rhs = row[button_count]
    raise "No solution for joltage machine" if left.all?(&:zero?) && rhs != 0
  end

  free_cols = (0...button_count).to_a - pivot_cols

  max_free = free_cols.to_h do |button_idx|
    touched = (0...counter_count).select { |i| button_masks[button_idx][i] == 1 }
    [button_idx, touched.empty? ? 0 : touched.map { |i| targets[i] }.min]
  end

  best_total = nil
  presses = Array.new(button_count, 0)

  assign_free = lambda do |free_pos|
    if free_pos == free_cols.length
      pivot_cols.each_with_index do |pivot_col, row_idx|
        row = rref[row_idx]
        rhs = row[button_count]
        free_cols.each { |fc| rhs -= row[fc] * presses[fc] }

        return unless rhs.denominator == 1
        value = rhs.numerator
        return if value < 0
        presses[pivot_col] = value
      end

      total = presses.sum
      best_total = total if best_total.nil? || total < best_total
      return
    end

    col = free_cols[free_pos]
    (0..max_free[col]).each do |v|
      presses[col] = v
      assign_free.call(free_pos + 1)
    end
  end

  assign_free.call(0)
  best_total
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
puts result == 18981 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)