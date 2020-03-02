require 'rubyllrb'

describe "constants" do
  it "should have declared a RED constant" do
    expect(RubyLLRB::RED).to eq true
  end

  it "should have declared a BLACK constant" do
    expect(RubyLLRB::BLACK).to eq false
  end
end

describe RubyLLRB::LLRB do
  subject { RubyLLRB::LLRB.new }

  def set_up(tree, size)
    [*1..size].shuffle.each { |x| tree.insert(x, x.to_s) }
    return tree
  end

  def find_max_depth node, depth
    return depth if node.nil?

    return [find_max_depth(node.left, depth + 1),
            find_max_depth(node.right, depth + 1)].max
  end

  it { is_expected.to be_instance_of RubyLLRB::LLRB }

  it { is_expected.to have_attributes(root_node: nil) }
  it { is_expected.to have_attributes(size: 0) }

  it { is_expected.to respond_to(:insert).with(2).arguments }
  it { is_expected.to respond_to(:search).with(1).arguments }
  it { is_expected.to respond_to(:each).with(0).arguments }
  it { is_expected.to respond_to(:pop).with(0).arguments }
  it { is_expected.to respond_to(:shift).with(0).arguments }
  it { is_expected.to respond_to(:delete).with(1).arguments }
  it { is_expected.to respond_to(:min).with(0).arguments }
  it { is_expected.to respond_to(:max).with(0).arguments }

  describe "#insert" do
    it "should accept a key and value" do
      expect { subject.insert(1, "hello") }.to_not raise_error
    end

    it "should increase the size if a new key is added" do
      subject.insert(1, :one)
      expect(subject.size).to eq 1
      subject.insert(2, :two)
      expect(subject.size).to eq 2
    end

    it "shouldn't increase the size if the key already exists" do
      subject.insert(1, :one)
      subject.insert(1, :two)
      expect(subject.size).to eq 1
    end

    it "should set the root to black" do
      subject.insert(1, :one)
      expect(subject.root_node.colour).to eq RubyLLRB::BLACK
    end

    it "should balance the tree (simple)" do
      subject.insert(1, :one)
      subject.insert(2, :two)
      subject.insert(3, :three)
      expect(subject.root_node.key).to eq 2
    end
    
    (1..5).each do |x|
      it "should balance the tree #{x}" do
        set_up(subject, 10**x)
        depth = find_max_depth(subject.root_node, 0)
        expect(depth).to be <= (2.1 * Math.log(10**x)).ceil
      end
    end
  end

  describe "#search" do
    it "should return a value when given a key" do
      subject.insert(1, :one)
      expect(subject.search(1)).to eq :one
    end

    it "should return nil when the tree is empty" do
      expect(subject.search(1)).to be_nil
    end

    it "should return nil when the tree doesn't contain a key" do
      subject.insert(1, :one)
      subject.insert(2, :two)
      subject.insert(3, :three)
      expect(subject.search(4)).to be_nil
    end
  end

  describe "#==" do
    it "should return true if both trees are empty" do
      other = RubyLLRB::LLRB.new
      expect(subject == other).to be true
    end

    it "should return false if it isn't a RubyLLRB::LLRB tree" do
      other = "A string"
      expect(subject == other).to be false
      other = 1
      expect(subject == other).to be false
      other = :symbol
      expect(subject == other).to be false
    end

    it "should return true if all keys and values are the same" do
      set_up(subject, 10)
      other = set_up(RubyLLRB::LLRB.new, 10)
      expect(subject == other).to be true
    end

    it "should return false if the sizes are different" do
      set_up(subject, 5)
      other = RubyLLRB::LLRB.new
      expect(subject == other).to be false
    end
  end

  describe "#each" do
    it "should iterate over the tree in order of the keys" do
      set_up(subject, 16)
      arr = []
      subject.each { |key, _| arr << key }
      expect(arr).to eq [*1..16]
    end
    
    it "should do nothing if the tree is empty" do
      arr = []
      subject.each { |key, _| arr << key }
      expect(arr).to eq []
    end
  end

  describe "#max" do
    it "should return nill if the tree is empty" do
      expect(subject.max).to be_nil
    end

    it "should return the max key-value pair" do
      set_up(subject, 10)
      expect(subject.max).to eq [10, 10.to_s]
      expect(subject.search(10)).to eq 10.to_s
      expect(subject.size).to eq 10
    end
  end

  describe "#pop" do
    it "should return nil if the tree is empty" do
      result = subject.pop
      expect(result).to be_nil
    end

    it "should delete and return the max key-value pair" do
      set_up(subject, 10)
      result = subject.pop
      expect(result).to eq [10, 10.to_s]
      expect(subject.search(10)).to be_nil
      expect(subject).to eq set_up(RubyLLRB::LLRB.new, 9)
    end
  end

  describe "#min" do
    it "should return nill if the tree is empty" do
      expect(subject.min).to be_nil
    end

    it "should return the min key-value pair" do
      set_up(subject, 10)
      expect(subject.min).to eq [1, 1.to_s]
      expect(subject.search(1)).to eq 1.to_s
      expect(subject.size).to eq 10
    end
  end

  describe "#shift" do
    it "should return nil if the tree is empty" do
      result = subject.shift
      expect(result).to be_nil
    end

    it "should delete and the return the value at the min key" do
      set_up(subject, 10)
      result = subject.shift
      expect(result).to eq [1, 1.to_s]
      expect(subject.search(1)).to be_nil
    end
  end

  describe "#delete" do
    it "should return nil if the tree is empty" do
      expect(subject.delete(1)).to be_nil
    end

    it "should return nil if the key doesn't exist" do
      set_up(subject, 10)
      expect(subject.delete(15)).to be_nil
      expect(subject.size).to eq 10
    end

    it "should delete and return the value of the key" do
      set_up(subject, 10)
      key = 7
      result = subject.delete(key)
      expect(result).to eq "7"
    end

    it "should delete the key" do
      set_up(subject, 10)
      key = rand(1..10)
      subject.delete key
      expect(subject.search key).to be_nil
    end

    it "should decrease the size" do
      set_up(subject, 10)
      key = rand(1..10)
      subject.delete key
      expect(subject.size).to eq 9
    end
  end
end

describe RubyLLRB::Node do
  let(:node) { RubyLLRB::Node.new(:key, :value) }
  subject { node }

  it { is_expected.to be_instance_of RubyLLRB::Node }

  it { is_expected.to have_attributes(colour: true) }
  it { is_expected.to have_attributes(key: :key) }
  it { is_expected.to have_attributes(value: :value) }
  it { is_expected.to have_attributes(left: nil) }
  it { is_expected.to have_attributes(right: nil) }
end
