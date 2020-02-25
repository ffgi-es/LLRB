require './lib/rubyllrb'
require './ext/cllrb'
require 'benchmark'

N0 = 50000
N1 = N0 / 100
num = ARGV[0] ? ARGV[0].to_i : 10000

def test_structures n
  puts "Testing for #{n} elements"

  initial_array = [*1..n].shuffle
  hash = Hash.new
  llrb = RubyLLRB::LLRB.new
  clrb = CLLRB::LLRB.new

  Benchmark.bm(16) do |x|
    puts "Insertion:"
    x.report("- hash:") do
      initial_array.each { |e| hash[e] = e.to_s }
    end
    x.report("- llrb:") do
      initial_array.each { |e| llrb.insert(e, e.to_s) }
    end
    x.report("- C tree:") do
      initial_array.each { |e| clrb[e] = e.to_s }
    end
    puts

    puts "Searching (#{N0} times):"
    x.report("- hash:") do
      N0.times { hash[rand(1..n)] }
    end
    x.report("- llrb:") do
      N0.times { llrb.search(rand(1..n)) }
    end
    x.report("- C tree:") do
      N0.times { clrb[rand(1..n)] }
    end
    puts

    puts "Returning size (#{N0} times):"
    x.report("- hash:") do
      N0.times { hash.size }
    end
    x.report("- llrb:") do
      N0.times { llrb.size }
    end
    x.report("- C tree:") do
      N0.times { clrb.size }
    end
    puts

    puts "Finding maximum (#{N1} times):"
    x.report("- hash:") do
      N1.times { hash.max }
    end
    x.report("- hash manual:") do
      N1.times { hash.reduce { |r, (k, v)| r[0] > k ? r : [k, v] } }
    end
    x.report("- llrb:") do
      N1.times { llrb.max }
    end
    x.report("- C tree:") do
      N1.times { clrb.max }
    end
    puts

    puts "Finding minimum (#{N1} times):"
    x.report("- hash:") do
      N1.times { hash.min }
    end
    x.report("- llrb:") do
      N1.times { llrb.min }
    end
    x.report("- C tree:") do
      N1.times { clrb.min }
    end
    puts

    puts "Iteration (once):"
    x.report("- hash unordered:") do
      hash.each { |k, v| "#{k.inspect}: #{v.inspect}" }
    end
    x.report("- hash ordered:") do
      hash.sort.each { |k, v| "#{k.inspect}: #{v.inspect}" }
    end
    x.report("- llrb:") do
      llrb.each { |k, v| "#{k.inspect}: #{v.inspect}" }
    end
    x.report("- C tree:") do
      clrb.each { |k, v| "#{k.inspect}: #{v.inspect}" }
    end
    puts

    puts "Deletion (#{n / 10} elements):"
    deletion_array = initial_array.sample(n / 10)
    x.report("- hash:") do
      deletion_array.each { |e| hash.delete(e) }
    end
    x.report("- llrb:") do
      deletion_array.each { |e| llrb.delete(e) }
    end
    puts

    puts "Delete maximum (#{N1} times):"
    x.report("- hash:") do
      N1.times { hash.delete(hash.max[0]) }
    end
    x.report("- llrb:") do
      N1.times { llrb.pop }
    end
    puts

    puts "Delete minimum (#{N1} times):"
    x.report("- hash:") do
      N1.times { hash.delete(hash.min[0]) }
    end
    x.report("- llrb:") do
      N1.times { llrb.shift }
    end
  end
end

test_structures num
