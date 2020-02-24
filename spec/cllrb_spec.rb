require '../ext/cllrb'

describe CLLRB::LLRB do
  subject { CLLRB::LLRB.new }

  describe "#[]" do
    it "should return nil for an empty tree" do
      expect(subject[1]).to be_nil
    end
  end
end
