require "json"

def fetch_puzzle_input(day = 1)
  url = "https://adventofcode.com/2025/day/#{day}/input"
  output = `node data-fetch.js "#{url}"`
  JSON.parse(output)
end