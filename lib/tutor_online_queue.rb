require 'singleton'

class TutorOnlineQueue
  include Singleton

  def initialize
    @queue = []
  end

  def push(id)
    @queue << id
  end

  def poll(num)
    @queue.shift(num)
  end

  def remove(id)
    @queue.delete(id)
  end
end