require 'csv'
module OrderParser
  extend self

  SHIFT_VALUES = { 'M' => 'morning', 'N' => 'noon', 'E' => 'evening' }
  KEY_FIELDS = [ :name, :address, :city, :state, :country ]
  OUR_COMPANY = { name: 'Larkin LLC', address: '1505 S BLOUNT ST', city: 'RALEIGH' }

  def perform(file, strategy: :create)
    messages = {errors: [], warnings: []}

    CSV.read(file.path).each_with_index do |row, index|
      next if index == 0
      row = row.map { |cell| cell.to_s.strip }

      origin_hash = { name: row[2],
                      address: row[3],
                      city: row[4],
                      state: row[5],
                      zip: row[6],
                      country: row[7] }

      destination_hash = { name: row[8],
                           address: row[9],
                           city: row[10],
                           state: row[11],
                           zip: row[12],
                           country: row[13] }

      delivery_date = Date.strptime(row[0], "%m/%d/%Y") rescue nil
      shift = SHIFT_VALUES[row[1]] || 'not_specified'

      order_hash = { delivery_date: delivery_date,
                     shift: shift,
                     phone: row[14],
                     number: row[16],
                     volume: row[17].to_f,
                     quantity: row[18].to_i }
      begin
        ActiveRecord::Base.transaction do
          origin = Location.find_by(origin_hash.select { |k, v| KEY_FIELDS.include? k })
          origin ||= Location.create!(origin_hash)
          destination = Location.find_by(destination_hash.select { |k, v| KEY_FIELDS.include? k })
          destination ||= Location.create!(destination_hash)
          reverse = destination == Location.find_by(OUR_COMPANY)
          order_hash = order_hash.merge(origin: origin, destination: destination, reverse: reverse)

          if strategy == 'update'
            next if Order.find_by(order_hash.merge(shift: Order.shifts[order_hash[:shift]]))
          end
          order = Order.create!(order_hash)
          warning_messages = []
          warning_messages << I18n.t('warnings.no_delivery_date') unless delivery_date
          warning_messages << I18n.t('warnings.no_phone') unless order_hash[:phone].present?
          warning_messages << I18n.t('warnings.no_number') unless order_hash[:number].present?
          warning_messages << I18n.t('warnings.invalid_origin_zip') unless origin_hash[:zip] =~ /\A\d{5}\Z/
          warning_messages << I18n.t('warnings.invalid_destination_zip') unless destination_hash[:zip] =~ /\A\d{5}\Z/
          warning_messages << I18n.t('warnings.large_order') if order.volume > Load::MAX_VOLUME

          messages[:warnings] = messages[:warnings] + warning_messages.map { |m| ["row: #{index}", "order uid: #{order.id}", "order number: #{order.number}", "order date: #{order.delivery_date}", m] }
        end
      rescue Exception => e
        messages[:errors] << ["row: #{index}", e.message]
      end
    end
    messages
  end

end
