require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "validations" do
    let(:order) { create :order }
    subject { order }
    it { should be_valid }

    context 'diffenece of locations' do
      before { order.destination = order.origin }
      it { should_not be_valid }
    end
  end
end
