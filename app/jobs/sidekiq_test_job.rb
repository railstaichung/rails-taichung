class SidekiqTestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"
  end
end
