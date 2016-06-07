require 'rails_helper'

RSpec.describe Load, type: :model do
  describe 'validations' do
    let(:load) { create :load }
    subject { load }
    it { should be_valid }

    context 'when load is not empty' do
      let(:first_order) { create :order, delivery_date: load.delivery_date, shift: load.shift }
      let(:second_order) { create :order, delivery_date: nil, shift: :not_specified }

      before do
        load.orders << first_order
        load.orders << second_order
      end

      context 'when delivery date is changed' do
        context 'when load delivery date conflicts with orders delivery dates' do
          before { load.update(delivery_date: load.delivery_date + 1.day) }
          it { should_not be_valid }
        end

        context 'when load delivery date doesnt conflict with orders delivery dates' do
          before do
            first_order.update(delivery_date: nil)
            load.update(delivery_date: load.delivery_date + 1.day)
          end
          it { should be_valid }
        end
      end

      context 'when shift is changed' do
        context 'when load shift conflicts with orders shifts' do
          before { load.update(shift: :evening) }
          it { should_not be_valid }
        end

        context 'when load shift doesnt conflict with orders shifts' do
          before do
            first_order.update(shift: :not_specified)
            load.update(shift: :evening)
          end
          it { should be_valid }
        end

        describe 'load complete validation' do
          it 'load should no be valid if reverse order is not last' do
            first_order.update!(position: 1, reverse: true)
            second_order.update!(position: 2)
            load.update(completed: true)
            expect(load.reload.completed).to be_falsey
            expect(load.errors.full_messages).to eq [
              "Orders should be in the end of load list if reverse"]
          end
        end
      end
    end

  end
end
