if RUBY_VERSION[0,3] == "1.9"
  require 'timeout'
else
  require File.dirname(__FILE__) + '/timeout.rb'
end

require 'benchmark'

# attempt to use hitimes, if it exists
begin
 require 'rubygems'
 require 'hitimes'
 Benchmark.module_eval { def self.realtime; Hitimes::Interval.measure { yield }; end } if Hitimes::Interval.respond_to? :measure

rescue LoadError
end

class BenchmarkRunner
  include Enumerable
  
  attr_reader :label, :times, :error
    
  def initialize(label, iterations, timeout)
    @iterations = iterations
    @timeout = timeout
    @label = label
    @times = []
    @rss = []
  end
  
  def each
    @times.each {|val| yield val }
  end
  
  def <=>(other)
    self.label <=> other.label
  end

  def have_rss?
   begin
    require 'rubygems'
    require 'sys/proctable'
    return true
   rescue Exception
   end
   return false
  end

  def current_rss
   if RUBY_PLATFORM =~ /mswin|mingw/
      Sys::ProcTable.ps(Process.pid).working_set_size
   else
     # linux etc
     Sys::ProcTable.ps(Process.pid).rss
   end
  end
  
  def run
    begin
      Timeout.timeout(@timeout) do
        @iterations.times do
          @times << Benchmark.realtime { yield }
          @rss << current_rss if have_rss? 
        end
      end
    rescue Timeout::Error
      @error = "Timeout: %.2f seconds" % (@timeout / @iterations.to_f)
    rescue Exception => e
      @error = "Error: #{e.message} #{e.class}"
    end          
  end
  
  def best
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
      "#{@label},#{@error}#{"," * (@iterations + 1)}"
    else
      "#{@label},#{@times.join(',')},%.15f,%.15f,#{@rss.join(',')}" % [mean, standard_deviation]
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
