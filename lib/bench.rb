require File.dirname(__FILE__) + '/timeout.rb'

class BenchmarkRunner
  include Enumerable
  include Timeout
  
  attr_reader :label, :times, :error
    
  def initialize(label)
    @label = label
    @times = []
  end
  
  def each
    @times.each {|val| yield val }
  end
  
  def <=>(other)
    self.label <=> other.label
  end
  
  def run(iterations, time_limit)
    begin
      timeout(time_limit) do
        iterations.times do
          t0 = Time.now.to_f
          yield
          t1 = Time.now.to_f
          @times << t1 - t0
        end
      end
    rescue Error
      @error = "Timeout: %.2f seconds" % (time_limit / iterations.to_f)
    rescue Exception => e
      @error = "Error: #{e.message}"
    end          
  end
  
  def best_time
    @times.min
  end

  def mean
    sum / @times.length
  end

  def standard_deviation
    Math.sqrt((1.0/@times.length) * squared_deviations)
  end
  
  def to_s
    if @error
      "#{@label}:\t#{@error}"
    else
      "#{@label}:\t%.8f\t%.8f" % [best_time, standard_deviation]
    end
  end
  
  private
  
  def sum
    @times.inject {|total, n| total + n }
  end

  def squared_deviations
    avg = mean
    @times.inject(0) {|total, x| total + (x - avg)**2 }
  end  
end