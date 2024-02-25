#!/usr/bin/env ruby

class ConnectFour
  COLORS = %i[blue red]
  CONS_TO_WIN = 4
  attr_reader :width, :height

  # We only need one method to check for matches in a given array
  # we want something else to get all combinations of arrays to check

  def initialize(width: 7, height: 6)
    @width = width
    @height = height
  end

  def last_row_index
    height - 1
  end

  def last_col_index
    width - 1
  end

  def notify_winner
    return unless winner = board_winner

    p "Congratulations, #{board_winner} wins!"
  end

  def board
    @board ||= (1..height).to_a.map do |_row|
      (1..width).to_a.map { |_col| false }
    end
  end
  alias_method :rows, :board

  def board_winner
    directional_arrays.each do |arr|
      result = directional_winner(arr)
      p [:dirwinner, arr, result] if result
      return result if result
    end

    nil
  end

  def directional_winner(arr)
    return unless arr

    red_win = arr.join.match?(/(red){4,}/)
    blue_win = arr.join.match?(/(blue){4,}/)
    p [:dirmatch, red_win, blue_win]
    if red_win
      "red"
    elsif blue_win
      "blue"
    end
  end

  def directional_arrays
    rows + columns + diagonals
  end

  def columns
    (0..last_col_index).to_a.map do |col|
      rows.map {|row| row[col] }
    end
  end

  def diagonals
    # add largest breadth to allow for shorter runs on the edges
    # if the height is larger than the width, matches COULD occur at lower rows
    offset = height - CONS_TO_WIN
    result = []
    (-offset..width + offset).to_a.each do |col|
      ltr = ltr_diagonal(col)
      rtl = rtl_diagonal(col)
      result << ltr if ltr.size
      result << rtl if rtl.size
    end

    result
  end

  def rtl_diagonal(col)
    return [] if height < CONS_TO_WIN

    expected_length = [height, col + 1].min
    return [] if expected_length < CONS_TO_WIN

    current_col = col
    row = 0
    result = []

    while current_col >= 0 && !(entry = rows.dig(row, current_col)).nil?
      result << entry unless entry.nil?
      current_col -= 1
      row += 1
    end

    result
  end

  def ltr_diagonal(col)
    # return early if not enough space to win
    # iterate over board from location
    # stop once no longer able to move
    # should always be at least 4 (CONS_TO_WIN), and at most 6 (height) or empty
    return [] if height < CONS_TO_WIN

    expected_length = [height, width - col].min
    return [] if expected_length < CONS_TO_WIN

    current_col = col.dup
    row = 0
    result = []

    while current_col < width && !(entry = rows.dig(row, current_col)).nil?
      result << entry unless entry.nil?
      current_col += 1
      row += 1
    end

    result
  end

  def add_to_column(col, color)
    top_col = top_of_column(col)
    return "Incorrect color" unless COLORS.include?(color.to_sym)
    return p "The ##{col} column is full!" if top_col < 0

    board[top_col][col] = color
    notify_winner
  end

  private

  def top_of_column(col)
    current_row = last_row_index

    while current_row >= 0
      break if rows[current_row][col] == false

      current_row -= 1
    end

    current_row
  end

end

p [:prepping]
cf = ConnectFour.new
cf.add_to_column 2, :blue
cf.add_to_column 2, :blue
cf.add_to_column 2, :blue
cf.add_to_column 2, :blue
p [:colwinner, cf.board_winner, cf.board]

cf = ConnectFour.new
cf.add_to_column 0, :blue
cf.add_to_column 1, :red
cf.add_to_column 1, :blue
cf.add_to_column 2, :red
cf.add_to_column 2, :red
cf.add_to_column 2, :blue
cf.add_to_column 3, :blue
cf.add_to_column 3, :red
cf.add_to_column 3, :red
cf.add_to_column 3, :blue
p [:diagonalwin, cf.board_winner, cf.board]
