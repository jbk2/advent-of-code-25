require "json"

def fetch_puzzle_input(day = 1)
  url = "https://adventofcode.com/2025/day/#{day}/input"
  output = `node data-fetch.js "#{url}"`
  JSON.parse(output)
end

################ ANSI STYLE HELPER ####################
BLACK   = 30
RED     = 31
GREEN   = 32
YELLOW  = 33
BLUE    = 34
MAGENTA = 35
CYAN    = 36
WHITE   = 37
RESET   = 0
BOLD    = 1
ITALIC  = 3
UNDERLINE = 4

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

####################################