class SimpleSpreadsheet
  OPERATORS = %w[- / + *]
  ROWS = ('A'..'Z').to_a.freeze
  DEFAULT_DEPTH = 9

  attr_reader :depth

  def initialize(depth: DEFAULT_DEPTH)
    @depth = depth
  end

  def matrix
    @matrix ||= Array.new(ROWS.size).map do |col|
      Array.new(depth)
    end
  end

  def get_cell(location)
    return unless location?(location)

    raw_value = matrix.dig(*coordinates(location))

    render_value(raw_value)
  end

  def render_value(value)
    return if value.blank?
    return calculate(value) if formula?(value)
    return value.to_i if number?(value) # An empty string will resolve to zero here
    return get_cell(value) if location?(value)

    value
  end

  def location?(str)
    str.match?(/\A[A-Z][0-9]+\z/)
  end

  def number?(str)
    str.match?(/\A[\d]+\z/)
  end

  def formula?(str)
    str.match?(/\A\=/)
  end

  def coordinates(str)
    [ROWS.index(str.first), str[1..-1].to_i]
  end

  def set_cell(location, value)
    row, col = coordinates(location)
    raise "Location out of bounds" if out_of_bounds?(row, col)

    matrix[row][col] = value
  end

  def out_of_bounds?(row, col)
    row > ROWS.size || col > depth || row < 0 || col < 0
  end

  def calculate(val)
    # splits and keeps captured group, ["A1", "-", "B2", ...]
    formula = val[1..-1].gsub(" ", "").split(/([?\-\+\/\*])/)
    return value_for(formula.first) if formula.length == 1
    return "NaN" if (formula.length - 1) % 2 != 0 # return if uneven formula
    
    result = formula.first
    formula[1..-1].each_with_index do |val, i|
      next if i % 2 != 0 # runs every third entry for (e.g., a - b)
      
      b_val = render_value(formula[i+1]) # could be location, or int
      
      result += process_formula(result, formula[i], b_val)
    end
    
    result
  end

  def process_formula(a, op, b)
    p [:process, a, op, b]
    case op
    when "-"
      a - b
    when "+"
      a + b
    when "/"
      a / b
    when "*"
      a * b
    else
      raise "Invalid Operator: #{op}"
    end
  end
end
