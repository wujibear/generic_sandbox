# The algorithm question was to build a calculator with expressions like T1 = T2, where one eventually equals a number, and you have to keep solving until you get the result. The second part of it involved adding addition and subtraction.

# Example:

# Part 1: Basic Calculator for Sequential Equations

# Write a program to evaluate a series of sequential equations. Each equation is in the form Tn = Tm where eventually one of the terms resolves to a number. Your task is to find the value of the last term.

# For example, given the following equations:

# T1 = T2
# T2 = T3
# T3 = 5

# The program should determine that T1 is 5.
# Part 2: Calculator with Addition and Subtraction

# Extend the program to handle equations with addition and subtraction.

# For example, given the following equations:

# T1 = T2 + 3
# T2 = T3 - 2
# T3 = 10

# The program should determine the value of T1.
class SequentialCalculator

  attr_reader :equations 
  VAR_KEY = "T"
  OPERATORS = %w[- +]

  def initialize(equations)
    @equations = equations
  end

  def process!
  end

  def equation_matrix
    @equation_matrix ||= equations.map do |equation|
      equation.gsub(/\s/, '').split('=')
    end
  end

  def solutions
    @solutions ||= {}
  end

  def single_value_location
    equation_matrix.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        next if col.to_i.zero?

        return [row_index, col_index]
      end
    end
  end

  def process_single_value
    row, col = single_value_location
    formula_index = col == 0 ? 1 : 0
    answer = equation_matrix[row][col].to_i
    formula = equation_matrix[row][formula_index]
    solutions[formula] = answer
  end

  def calculate(val, answer)
    formula = val.gsub(" ", "").split(/([?\-\+])/)
    a_val, op, b_val = formula
    
    if number?(a_val)
    elsif number?(b_val)
    end

    formula.each_with_index do |val, i|
      next if OPERATORS.include? val
      
      b_val = render_value(formula[i+1]) # could be location, or int
      
      result += process_formula(result, formula[i], b_val)
    end
    
    result
  end

  def number?(str)
    str.match?(/\A[\d]+\z/)
  end

  def divide(str, result)
    match_value = str.match(/\A#{VAR_KEY}([\d]*)/)
    mult = match_value.captures.first.to_i

    result.to_f / mult.to_f
  end

  def process_formula(a, op, b)
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