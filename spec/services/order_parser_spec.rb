require 'rails_helper'

RSpec.describe OrderParser do
  describe '.perform' do
    let(:example_filename) { Rails.root.join('spec/fixtures/weekly_schedule.csv') }
    let(:short_example_filename) { Rails.root.join('spec/fixtures/weekly_schedule1.csv') }
    let(:invalid_example_filename) { Rails.root.join('spec/fixtures/weekly_schedule2.csv') }

    context 'when shedule file is valid' do
      it 'should parse shedule csv and create orders' do
        messages = File.open(example_filename) do |file|
          OrderParser.perform(file)
        end
        expect(messages[:errors]).to be_empty
        expect(messages[:warnings].map { |w| [w[0], w[4]] }).to eq [
          ["row: 44", I18n.t('warnings.invalid_origin_zip')],
          ["row: 54", I18n.t('warnings.large_order')],
          ["row: 249", I18n.t('warnings.no_delivery_date')],
          ["row: 331", I18n.t('warnings.no_number')]
        ]
        expect(Order.count).to eq 401
      end

      it 'should not create duplicate orders when strategy update' do
        File.open(example_filename) do |file|
          OrderParser.perform(file)
        end
        messages = File.open(example_filename) do |file|
          OrderParser.perform(file, strategy: 'update')
        end
        expect(messages[:errors]).to be_empty
        expect(Order.count).to eq 401
      end

      it 'should create locations without duplication' do
        messages = File.open(short_example_filename) do |file|
          OrderParser.perform(file)
        end
        expect(messages[:errors]).to be_empty
        expect(Location.count).to eq 11
      end

      it 'should create locations with all fields correctly' do
        File.open(short_example_filename) { |file| OrderParser.perform(file) }
        store_location = Location.find_by(name: 'Larkin LLC')
        client_location = Location.find_by(name: 'Dr. Hettie Conroy')
        attrs = %w(address city state zip country)
        expect(attrs.map { |attr| store_location.send(attr.to_sym) }).to eq [
          '1505 S BLOUNT ST', 'RALEIGH', 'NC', '27603', 'US']
        expect(attrs.map { |attr| client_location.send(attr.to_sym) }).to eq [
          '1057 GLEN REILLY DRIVE', 'FAYETTEVILLE', 'NC', '28314', 'US']
      end

      it 'should create orders with all fields correctly' do
        File.open(short_example_filename) { |file| OrderParser.perform(file) }

        first_order = Order.find_by(number: '500400090')
        second_order = Order.find_by(number: '500393641')

        attrs = %w(delivery_date shift phone volume quantity)
        expect(attrs.map { |attr| first_order.send(attr.to_sym) }).to eq [
          Date.parse('2014-09-16'), 'not_specified', '(372)327-5842', 75.6, 2 ]
        expect(first_order.origin).to eq Location.find_by(name: 'Larkin LLC')
        expect(first_order.destination).to eq Location.find_by(name: 'Shayne Dooley')
        expect(first_order.reverse).to be_falsey

        expect(attrs.map { |attr| second_order.send(attr.to_sym) }).to eq [
          Date.parse('2014-09-17'), 'evening', '1-404-888-3360', 15.53, 1 ]
        expect(second_order.origin).to eq Location.find_by(name: 'Dr. Hettie Conroy')
        expect(second_order.destination).to eq Location.find_by(name: 'Larkin LLC')
        expect(second_order.reverse).to be_truthy
      end
    end

    context 'when shedule file is invalid' do
      it 'should parse shedule csv and create orders for right rows' do
        messages = File.open(invalid_example_filename) { |file| OrderParser.perform(file) }
        expect(messages[:errors]).not_to be_empty
        expect(Order.count).to eq 7
        expect(Location.count).to eq 6
      end

      it 'should return errors info for each bad row' do
        messages = File.open(invalid_example_filename) { |file| OrderParser.perform(file) }
        expect(messages[:errors]).to eq [
          ["row: 1", "Validation failed: Zip format should be like 12345 or 12345-1234"],
          ["row: 4", "Validation failed: Name can't be blank"],
          ["row: 5", "Validation failed: Destination should be different from the origin"],
          ["row: 6", "Validation failed: City can't be blank"],
          ["row: 9", "Validation failed: Address can't be blank"],
          ["row: 11", "Validation failed: Destination should be different from the origin"]]
      end
    end

  end
end

