require 'rubyllrb'
include RubyLLRB

describe "constants" do
  it "should have declared a RED constant" do
    expect(RED).to eq true
  end

  it "should have declared a BLACK constant" do
    expect(BLACK).to eq false
  end
end

describe LLRB do
  let(:llrb) { LLRB.new }
  subject { llrb }

  it { is_expected.to be_instance_of LLRB }

  it { is_expected.to have_attributes(root_node: nil) }
  it { is_expected.to have_attributes(size: 0) }

  it { is_expected.to respond_to(:insert).with(2).arguments }
  it { is_expected.to respond_to(:search).with(1).arguments }
  it { is_expected.to respond_to(:each).with(0).arguments }

  describe "#insert" do
    it "should accept a key and value" do
      expect{ subject.insert(1, "hello") }.to_not raise_error
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
      expect(subject.root_node.colour).to eq BLACK
    end

    it "should balance the tree (simple)" do
      subject.insert(1, :one)
      subject.insert(2, :two)
      subject.insert(3, :three)
      expect(subject.root_node.key).to eq 2
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

  describe "#each" do
    it "should iterate over the tree in order of the keys" do
      [*1..16].shuffle.each { |x| subject.insert(x, x.to_s) }
      arr = []
      subject.each { |key, value| arr << key }
      expect(arr).to eq [*1..16]
    end
    
    it "should do nothing if the tree is empty" do
      arr = []
      subject.each { |key, value| arr << key }
      expect(arr).to eq []
    end
  end
end

describe Node do
  let(:node) { Node.new(:key, :value) }
  subject { node }

  it { is_expected.to be_instance_of Node }

  it { is_expected.to have_attributes(colour: true) }
  it { is_expected.to have_attributes(key: :key) }
  it { is_expected.to have_attributes(value: :value) }
  it { is_expected.to have_attributes(left: nil) }
  it { is_expected.to have_attributes(right: nil) }
end
