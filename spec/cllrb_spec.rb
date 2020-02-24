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
  end

  describe "#size" do
    it "should be zero for a tree with no nodes" do
      expect(subject.size).to eq 0
    end
  end
end
