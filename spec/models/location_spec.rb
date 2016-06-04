require 'rails_helper'

RSpec.describe Location, type: :model do
  describe "validations" do
    let(:location) { create :location }
    subject { location }
    it { should be_valid }
  end
end
