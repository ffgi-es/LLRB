require '../ext/cllrb'

describe CLLRB::LLRB do
  subject { CLLRB::LLRB.new }

  describe "#[]" do
    it "should return nil for an empty tree" do
      expect(subject[1]).to be_nil
    end

    it "should return the value if an element has been inserted" do
      subject[1] = "one"
      expect(subject[1]).to eq "one"
    end

    it "should return the correct value for the key" do
      subject[1] = "one"
      subject[2] = "two"
      subject[3] = "three"
      expect(subject[1]).to eq "one"
      expect(subject[2]).to eq "two"
      expect(subject[3]).to eq "three"
    end

    it "should return nil when a key doesn't exist" do
      subject[1] = "one"
      expect(subject[2]).to be_nil
    end

    class Num
      attr_reader :value

      def initialize(n)
        @value = n
      end

      def <=> other
        return @value <=> other.value
      end
    end

    it "should search through roughly 2·ln(n) keys at most" do
      [*1..10_000].shuffle.each { |x| subject[Num.new(x)] = x.to_s }
      [*1..10_000].sample(100).map { |x| Num.new(x) }.each do |x|
        expect(x).to receive(:<=>)
          .at_most((2 * Math.log(10_000)).ceil)
          .and_call_original
        expect(subject[x]).to eq x.value.to_s
      end
    end
  end

  describe "#[]=" do
    it "should return the value assigned to the key" do
      expect(subject[1] = "two").to eq "two"
    end

    it "should increase the size by 1" do
      subject[1] = "blank"
      expect(subject.size).to eq 1
      subject[4] = "random"
      expect(subject.size).to eq 2
    end

    it "should update the value of an en existing key" do
      subject[3] = "hello"
      subject[3] = "world"
      expect(subject[3]).to eq "world"
    end

    it "should not increase the size when updating" do
      subject[3] = "hello"
      subject[3] = "world"
      expect(subject.size).to eq 1
    end
  end

  describe "#size" do
    it "should be zero for a tree with no nodes" do
      expect(subject.size).to eq 0
    end
  end

  describe "#max" do
    it "should return nil for an empty tree" do
      expect(subject.max).to be_nil
    end

    it "should return an array for one item in a tree" do
      subject[5] = "blanket"
      expect(subject.max).to eq [5, "blanket"]
    end

    it "should return the max for 10 randomly inserted pairs" do
      [*1..10].shuffle.each { |x| subject[x] = x.to_s }
      expect(subject.max).to eq [10, "10"]
    end
  end

  describe "#min" do
    it "should return nil for an empty tree" do
      expect(subject.min).to be_nil
    end

    it "should return an array for one item in a tree" do
      subject[13] = "boooom"
      expect(subject.min).to eq [13, "boooom"]
    end

    it "should return the min for 10 randomly inserted pairs" do
      [*1..10].shuffle.each { |x| subject[x] = x.to_s }
      expect(subject.min).to eq [1, "1"]
    end
  end

  describe "#each" do
    it "should do nothing with an empty tree" do
      arr = []
      subject.each { |k, v| arr << [k, v] }
      expect(arr).to eq []
    end

    it "should execute the block for a single element" do
      subject[11] = "block run"
      arr = []
      subject.each { |k, v| arr << [v, k] }
      expect(arr).to eq [["block run", 11]]
    end

    it "should excute the block for each element in order" do
      [*1..30].shuffle.each { |x| subject[x] = x.to_s }
      arr = []
      subject.each { |k, v| arr << [k, v] }
      expected_arr = [*1..30].map { |x| [x, x.to_s] }
      expect(arr).to eq expected_arr
    end

    it "should do nothing if not given a block" do
      [*1..30].shuffle.each { |x| subject[x] = x.to_s }
      expect { subject.each }.to raise_error ArgumentError, "Expected block"
    end
  end

  describe "#pop" do
    it "should return nil for an empty tree" do
      expect(subject.pop).to be_nil
    end

    it "should return the only element in a tree of one key-pair" do
      subject[4] = "popping"
      expect(subject.pop).to eq [4, "popping"]
    end

    it "should remove the element from from the tree" do
      subject[5] = "remove pop"
      subject.pop
      expect(subject[5]).to be_nil
      expect(subject.size).to eq 0
    end

    it "should return and remove the maximum element from a tree" do
      [*1..10].shuffle.each { |x| subject[x] = x.to_s }
      expect(subject.pop).to eq [10, "10"]
      expect(subject[10]).to be_nil
      expect(subject.size).to eq 9
    end
  end

  describe "#shift" do
    it "should return nil for an empty tree" do
      expect(subject.shift).to be_nil
    end
  end
end
