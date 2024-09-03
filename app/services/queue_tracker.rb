# After seeing the success of Instacart, you've decided to start your own competing grocery delivery business.

# You venture out on your own and start by taking customer's orders.
#  For a given array of orders with the format [duration, time], where:
# 	•	duration represents how long it takes to fulfill their order as an integer of time units
# 	•	time represents when the customer placed their order as an integer of abstract time units
# Calculate the lowest average wait time of your customers to receive their orders. Average = sum of each customers’ wait time / # of orders

# Assumptions
# 	•	You must fulfill orders in the order in which customers placed them (i.e. by time)
# 	•	You can only work on one order at a time

# Example
# [ [4,1], [5,2], [2,3] ]
# 	•	First order is placed at time 1 and takes 4 times units to fulfill. The customer needs to wait 4 time units
# 	•	Second order is placed at time 2. The customer needs to wait 3 time units for you to finish the first order. Their order takes 5 time units. The customer needs to wait 8 time units
# 	•	Third order is placed at time 3. The customer needs to wait 7 time units for you to finish the first two orders. Their order takes 2 time units. The customer needs to wait 9 time units
# 	•	The average wait time is (4+8+9)/3 = 7.0 time units

# Diagram of this example:

# 	•	[execution time limit] 4 seconds (rb)
# 	•	[memory limit] 1 GB
# 	•	[input] array.array.integer orders Orders in the format of [duration, time] Orders are not sorted
# 	•	[output] float Average customer wait time

class QueueTracker
  class Order
    attr_reader :start_time, :duration, :queue, :id
    delegate :sorted_orders, to: :queue

    def initialize(duration:, start_time:, queue:, id:)
      @duration = duration
      @start_time = start_time
      @queue = queue
      @id = id
    end

    # prev guy time from now
    # wait_time
    def end_time
      process_start_time + duration
    end

    # total time to completion
    def wait_time
      end_time - start_time
    end

    def process_start_time
      return start_time unless previous_order

      previous_order.end_time
    end

    def previous_order
      return if sorted_index <= 0

      sorted_orders[sorted_index - 1]
    end

    def first?
      !previous_order
    end

    def sorted_index
      @sorted_index ||= sorted_orders.index { |order| order.id == id}
    end
  end

  attr_reader :order_data

  def initialize(order_data)
    @order_data = order_data
  end

  def sorted_orders
    @sorted_orders ||= order_data.
      sort_by { |order| order[1] }.
      map.with_index do |(duration, start_time), i|
        Order.new(duration: duration, start_time: start_time, queue: self, id: i)
      end
  end

  def average_wait_time
    total_wait.to_f / sorted_orders.size.to_f
  end

  def total_wait
    sorted_orders.inject(0) { |sum, order| sum + order.wait_time }
  end
end