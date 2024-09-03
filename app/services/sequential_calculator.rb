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

  attr_reader :equations, :solved_keys 
  OPERATORS = %w[- +]

  def initialize(equations)
    @equations = equations
    @solved_keys = []

    while incomplete?
      resolve_solveable_values!
    end
  end

  def solutions
    @solutions ||= equations.each_with_object({}) do |equation, acc|
      key, formula = equation.gsub(/\s/, '').split('=')
      if number?(formula)
        formula = formula.to_i 
        solved_keys << key
      end

      acc[key] = formula
    end
  end

  def resolve_solveable_values!
    solutions.each do |(key, value)|
      next if number?(value)
      next unless solveable?(value)

      solutions[key] = solve(value)
      solved_keys << key
    end
  end

  def solveable?(value)
    value.match?(solved_keys.join("|"))
  end

  def solve(value)
    key = value.match("(#{solved_keys.join('|')})").captures.first
    result = value.gsub(key, solutions[key].to_s) # avoids string interpolation issue
    a_val, b_val = result.split(/[\+\-]/).map(&:to_i)
    return a_val if b_val.blank?

    if value.match?(/\+/)
      a_val + b_val
    else
      a_val - b_val
    end
  end

  def number?(str)
    return true if str.is_a?(Integer)

    str.match?(/\A[\d]+\z/)
  end

  def incomplete?
    solved_keys.length < solutions.keys.length
  end
end