# Word anagrams (with duplicates)
# Do whatever you wish with this code as long as you don't harm endangered species
# Giovanni Intini <intinig@gmail.com>

class String
  def swap(i)
    tmp = self[0,1]
    self[0] = self[i]
    self[i] = tmp
    self
  end
  
  def permutations
    return [self] if size == 1

    results = []
    tmp = self
    size.times do |pos|
      tmp.swap(pos)
      partial_results = tmp[1..-1].permutations
      partial_results.each_index do |i|
        partial_results[i] = tmp[0,1] + partial_results[i]
      end
      results << partial_results
    end
    results.flatten
  end
end 

puts "alongword".permutations.size