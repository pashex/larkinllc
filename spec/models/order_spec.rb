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

    context 'load add order validations' do
      let(:load) { create :load }
      let(:first_order) { create :order, delivery_date: load.delivery_date, shift: load.shift }
      let(:second_order) { create :order, delivery_date: load.delivery_date, shift: load.shift }

      before do
        load.orders << first_order
      end

      context 'when order doesnt conflict with load' do
        it 'should be added to load' do
          expect(load.orders).to be_include(first_order)
          expect(first_order.errors).to be_empty
        end
      end

      describe '#check_orders_delivery_date' do
        it 'should not add order to load with other delivery date' do
          second_order.update(delivery_date: load.delivery_date + 1.day)

          load.orders << second_order
          expect(load.reload.orders).not_to be_include(second_order)
          expect(second_order.errors).not_to be_empty
          expect(second_order.errors.full_messages).to eq [
            "Load delivery date should be same as order delivery date"]
        end

        it 'should add order to load with empty delivery date' do
          second_order.update(delivery_date: nil)
          load.orders << second_order
          expect(load.orders).to be_include(second_order)
          expect(second_order.errors).to be_empty
        end
      end

      describe '#check_orders_shift' do
        it 'should not add order to load with other shift' do
          second_order.update(shift: :evening)

          load.orders << second_order
          expect(load.reload.orders).not_to be_include(second_order)
          expect(second_order.errors).not_to be_empty
          expect(second_order.errors.full_messages).to eq [
            "Load shift should be same as order shift"]
        end

        it 'should add order with not specified shift to load with any shift' do
          second_order.update(shift: :not_specified)
          load.orders << second_order
          expect(load.orders).to be_include(second_order)
          expect(second_order.errors).to be_empty
        end
      end

      describe '#check_load_volume' do
        it 'should not add order to load when max volume exceeded' do
          load.update(volume: 20.0)
          second_order.update(volume: 1390.0)

          load.orders << second_order
          expect(load.reload.orders).not_to be_include(second_order)
          expect(second_order.errors).not_to be_empty
          expect(second_order.errors.full_messages).to eq [
            "Load max volume exceeded"]
        end

        it 'should add reverse order even if the maximum volume is exceeded' do
          load.update(volume: 1400.0)
          second_order.update(volume: 20.0, reverse: true)

          load.orders << second_order
          expect(load.reload.orders).to be_include(second_order)
          expect(second_order.errors).to be_empty
        end

        it 'should not add reverse order if the maximum reverse volume is exceeded' do
          load.update(reverse_volume: 1200.0)
          second_order.update(volume: 300.0, reverse: true)

          load.orders << second_order
          expect(load.reload.orders).not_to be_include(second_order)
          expect(second_order.errors).not_to be_empty
          expect(second_order.errors.full_messages).to eq [
            "Load max volume exceeded"]
        end
      end

    end
  end
end
