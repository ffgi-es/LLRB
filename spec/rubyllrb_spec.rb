require 'rubyllrb'
include RubyLLRB

describe LLRB do
  let(:llrb) { LLRB.new }
  subject { llrb }

  it { is_expected.to be_instance_of LLRB }
end
