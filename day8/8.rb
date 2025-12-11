require_relative "../utils"
require 'benchmark'

class Coord
  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  attr_reader :x, :y, :z  
end

class Edge
  def initialize(distance, coord_a, coord_b)
    @distance = distance
    @coord_a = coord_a
    @coord_b = coord_b
  end

  attr_reader :distance, :coord_a, :coord_b
end

def hypotenuse(side_1, side_2)
  Math.sqrt((side_1 ** 2) + (side_2 ** 2 )).ceil(2)
end

def straight_line_distance_between(coord_a, coord_b)
  relative_x = (coord_a.x - coord_b.x).abs
  relative_y = (coord_a.y - coord_b.y).abs
  relative_z = (coord_a.z - coord_b.z).abs

  two_d_hypotenuse = hypotenuse(relative_x, relative_y)
  three_d_hypotenuse = hypotenuse(two_d_hypotenuse, relative_z)
end

def create_coords_array(coords_strings)
  coords_strings.reject(&:empty?).map do |coord_str|
    Coord.new(*coord_str.split(",").map(&:to_i))
  end
end

def largest_3_sum(coords_strings, no_of_connections = nil)
  coords_array = create_coords_array(coords_strings)
  coords_count = coords_array.length
  edges = []
  
  coords_array.each_with_index do |coord_a, index|
    coord_b_index = index + 1

    while coord_b_index < coords_count
      coord_b = coords_array[coord_b_index] 
      distance = straight_line_distance_between(coord_a, coord_b)
      edges << Edge.new(distance, coord_a, coord_b)
      coord_b_index += 1
    end
  end

  sorted_edges = edges.sort_by { _1.distance }
  selected_edges = no_of_connections ? sorted_edges[0...no_of_connections] : sorted_edges
  
  circuits_tracker = make_connections(selected_edges)
  circuits_tracker.circuits.map {|circuit| circuit[:nodes].size }.max(3).reduce(&:*)
end

def connecting_coord_x_distance(coords_strings)
  coords_array = create_coords_array(coords_strings)
  coords_count = coords_array.length
  edges = []

  coords_array.each_with_index do |coord_a, index|
    coord_b_index = index + 1

    while coord_b_index < coords_count
      coord_b = coords_array[coord_b_index] 
      distance = straight_line_distance_between(coord_a, coord_b)
      edges << Edge.new(distance, coord_a, coord_b)
      coord_b_index += 1
    end
  end

  sorted_edges = edges.sort_by { _1.distance }
  make_connections(sorted_edges)
end

def make_connections(sorted_edges_array)
  tracker = CircuitTracker.new
  connections_made = 0
  
  sorted_edges_array.each do |edge|
    if tracker.add_edge(edge)
      connections_made += 1
      puts "no of circuits = #{tracker.circuits.length}"
      # count number of circuits down when zero multiple the xs of the two coord in the latest edge
      # 
    end
  end
  
  tracker
end

class CircuitTracker
  def initialize()
    @node_to_circuit_ids = {}
    @circuits = {}
    @next_circit_id = 0
  end

  def add_edge(edge)
    coord_a, coord_b = edge.coord_a, edge.coord_b
    circuit_a_id = @node_to_circuit_ids[coord_a]
    circuit_b_id = @node_to_circuit_ids[coord_b]

      # where neither present in any existing circuits
    if !circuit_a_id && !circuit_b_id
      circuit_id = @next_circit_id += 1
      @circuits[circuit_id] = { nodes: Set[coord_a, coord_b], edges: [edge] }
      @node_to_circuit_ids[coord_a] = circuit_id
      @node_to_circuit_ids[coord_b] = circuit_id
      # puts("new circuit added #{circuit_id}, circuit count=> ", @circuits.keys.length)
      # extend circuit a
    elsif circuit_a_id && !circuit_b_id
      @circuits[circuit_a_id][:nodes].add(coord_b)
      @circuits[circuit_a_id][:edges] << edge
      @node_to_circuit_ids[coord_b] = circuit_a_id
      # puts("coord b #{coord_b} added to circuit_a #{circuit_a_id}, circuit count=> ", @circuits.keys.length)
      
      # extend circuit b
    elsif !circuit_a_id && circuit_b_id
      @circuits[circuit_b_id][:nodes].add(coord_a)
      @circuits[circuit_b_id][:edges] << edge
      @node_to_circuit_ids[coord_a] = circuit_b_id
      # puts("coord a #{coord_a} added to circuit_b #{circuit_b_id}, circuit count=> ", @circuits.keys.length)
      
      # both in same circuit already
    elsif circuit_a_id == circuit_b_id
      # puts("both coord_a; #{coord_a} and coord_b #{coord_b} are already in the same curcuit; #{circuit_a_id}, circuit count=> ", @circuits.keys.length)
      # @circuits[circuit_a_id][:edges] << edge
      return false
      # both are in circuits but not the same
    elsif circuit_a_id && circuit_b_id && (circuit_a_id != circuit_b_id)
      merge_circuits(circuit_a_id, circuit_b_id, edge)
      # puts("both coord_a; #{coord_a} and coord_b #{coord_b} are already in curcuits, but different ones, merging them to circuit_a #{circuit_a_id}, circuit count=> ", @circuits.keys.length)
    end

    return true
  end

  def merge_circuits(circuit_a_id, circuit_b_id, edge)
    circuit_a = @circuits[circuit_a_id]
    circuit_b = @circuits[circuit_b_id]

    circuit_a[:nodes].merge(circuit_b[:nodes])
    circuit_a[:edges].concat(circuit_b[:edges])
    circuit_a[:edges] << edge

    circuit_b[:nodes].each { |node| @node_to_circuit_ids[node] = circuit_a_id }
    @circuits.delete(circuit_b_id)
  end

  def circuits
    @circuits.values
  end
end

####################################
REAL_DATA = fetch_puzzle_input(8)
TEST_DATA = [
  "162,817,812",
  "57,618,57",
  "906,360,560",
  "592,479,940",
  "352,342,300",
  "466,668,158",
  "542,29,236",
  "431,825,988",
  "739,650,466",
  "52,470,668",
  "216,146,977",
  "819,987,18",
  "117,168,530",
  "805,96,715",
  "346,949,466",
  "970,615,88",
  "941,993,340",
  "862,61,35",
  "984,92,344",
  "425,690,689"
]


# coord_a = Coord.new(162, 817, 812)
# coord_b = Coord.new(425, 690, 689)
# coord_c = Coord.new(984, 92, 344)


# puts largest_3_sum(TEST_DATA)

puts "Running test 1"
result = largest_3_sum(TEST_DATA, 10)
puts result === 40 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

puts "Running real data test 1"
result = largest_3_sum(REAL_DATA, 1000)
puts result === 72150 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running test 2"
# result = larges_3_sum(TEST_DATA)
# puts result === 40 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)

# puts "Running real data test 2"
# time = Benchmark.measure do
#   result = path_count(REAL_DATA)
# end
# puts 'time taken -> ', time
# puts result === 18818811755665 ? colorize("test Passed", 32) : colorize("test failed with result of #{result}", 31)