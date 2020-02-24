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
  end

  describe "#[]=" do
    it "should return the value assigned to the key" do
      expect(subject[1] = "two").to eq "two"
    end
  end

  describe "#size" do
    it "should be zero for a tree with no nodes" do
      expect(subject.size).to eq 0
    end
  end
end
