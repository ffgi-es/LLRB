require './lib/rubyllrb'
require 'benchmark'

N = 50000
num = ARGV[0] ? ARGV[0].to_i : 10000

def test_structures n
  puts "Testing for #{n} elements"

  initial_array = [*1..n].shuffle
  hash = Hash.new
  llrb = RubyLLRB::LLRB.new

  Benchmark.bm(16) do |x|
    puts "Insertion:"
    x.report("- hash:") do
      initial_array.each { |e| hash[e] = e.to_s }
    end
    x.report("- llrb:") do
      initial_array.each { |e| llrb.insert(e, e.to_s) }
    end

    puts "Searching:"
    x.report("- hash:") do
      N.times { hash[rand(1..n)] }
    end
    x.report("- llrb:") do
      N.times { llrb.search(rand(1..n)) }
    end

    puts "Finding maximum:"
    x.report("- hash:") do
      (N / 100).times { hash.max }
    end
    x.report("- llrb:") do
      (N / 100).times { llrb.max }
    end

    puts "Finding minimum:"
    x.report("- hash:") do
      (N / 100).times { hash.min }
    end
    x.report("- llrb:") do
      (N / 100).times { llrb.min }
    end

    puts "Deletion:"
    deletion_array = initial_array.sample(n / 10)
    x.report("- hash:") do
      deletion_array.each { |e| hash.delete(e) }
    end
    x.report("- llrb:") do
      deletion_array.each { |e| llrb.delete(e) }
    end

    puts "Delete minimum:"
    x.report("- hash:") do
      (N / 100).times { hash.delete(hash.max[0]) }
    end
    x.report("- llrb:") do
      (N / 100).times { llrb.pop }
    end

    puts "Delete minimum*:"
    x.report("- hash:") do
      (N / 100).times { hash.delete(hash.min[0]) }
    end
    x.report("- llrb:") do
      (N / 100).times { llrb.shift }
    end

    puts "Iteration:"
    x.report("- hash unordered:") do
      hash.each { |k, v| "#{k.inspect}: #{v.inspect}" }
    end
    x.report("- hash ordered:") do
      hash.sort.each { |k, v| "#{k.inspect}: #{v.inspect}" }
    end
    x.report("- llrb:") do
      llrb.each { |k, v| "#{k.inspect}: #{v.inspect}" }
    end
  end
end

test_structures num
