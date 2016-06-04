require 'rails_helper'

RSpec.describe OrderParser do
  describe '.perform' do
    context 'when shedule file is valid' do
      it 'should parse shedule csv and create orders' do
        errors = OrderParser.perform(Rails.root.join('spec/fixtures/weekly_schedule.csv'))
        expect(errors).to be_empty
        expect(Order.count).to eq 401
      end

      it 'should create locations without duplication' do
        errors = OrderParser.perform(Rails.root.join('spec/fixtures/weekly_schedule1.csv'))
        expect(errors).to be_empty
        expect(Location.count).to eq 11
      end

      it 'should create locations with all fields correctly' do
        OrderParser.perform(Rails.root.join('spec/fixtures/weekly_schedule1.csv'))
        store_location = Location.find_by(name: 'Larkin LLC')
        client_location = Location.find_by(name: 'Dr. Hettie Conroy')
        attrs = %w(address city state zip country)
        expect(attrs.map { |attr| store_location.send(attr.to_sym) }).to eq [
          '1505 S BLOUNT ST', 'RALEIGH', 'NC', '27603', 'US']
        expect(attrs.map { |attr| client_location.send(attr.to_sym) }).to eq [
          '1057 GLEN REILLY DRIVE', 'FAYETTEVILLE', 'NC', '28314', 'US']
      end

      it 'should create orders with all fields correctly' do
        OrderParser.perform(Rails.root.join('spec/fixtures/weekly_schedule1.csv'))

        first_order = Order.find_by(number: '500400090')
        second_order = Order.find_by(number: '500393641')

        attrs = %w(delivery_date shift phone volume quantity)
        expect(attrs.map { |attr| first_order.send(attr.to_sym) }).to eq [
          Date.parse('2014-09-16'), 'not_specified', '(372)327-5842', 75.6, 2 ]
        expect(first_order.origin).to eq Location.find_by(name: 'Larkin LLC')
        expect(first_order.destination).to eq Location.find_by(name: 'Shayne Dooley')

        expect(attrs.map { |attr| second_order.send(attr.to_sym) }).to eq [
          Date.parse('2014-09-17'), 'evening', '1-404-888-3360', 15.53, 1 ]
        expect(second_order.origin).to eq Location.find_by(name: 'Dr. Hettie Conroy')
        expect(second_order.destination).to eq Location.find_by(name: 'Larkin LLC')
      end
    end

    context 'when shedule file is invalid' do
      it 'should parse shedule csv and create orders for right rows' do
        errors = OrderParser.perform(Rails.root.join('spec/fixtures/weekly_schedule2.csv'))
        expect(errors).not_to be_empty
        expect(Order.count).to eq 8
        expect(Location.count).to eq 7
      end

      it 'should return errors info for each bad row' do
        errors = OrderParser.perform(Rails.root.join('spec/fixtures/weekly_schedule2.csv'))
        expect(errors).to eq [
          ["row: 4", "Validation failed: Name can't be blank"],
          ["row: 5", "Validation failed: Destination should be different from the origin"],
          ["row: 6", "Validation failed: City can't be blank"],
          ["row: 9", "Validation failed: Address can't be blank"],
          ["row: 11", "Validation failed: Destination should be different from the origin"]]
      end
    end

  end
end

