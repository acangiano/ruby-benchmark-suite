class Array
  def qsort
    return [] if self.empty?
    pivot, *tail = self
    (tail.select {|el| el < pivot }).qsort + [pivot] +
      (tail.select {|el| el >= pivot }).qsort
  end  
end

array = File.read("random.input").split(/\n/).map!{|n| n.to_i }
puts "Quicksort verified." if array.qsort == array.sort
