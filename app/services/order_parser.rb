require 'csv'
module OrderParser
  extend self

  SHIFT_VALUES = { 'M' => 'morning', 'N' => 'noon', 'E' => 'evening' }
  KEY_FIELDS = [ :name, :address, :city, :state, :country ]
  OUR_COMPANY = { name: 'Larkin LLC', address: '1505 S BLOUNT ST', city: 'RALEIGH' }

  def perform(filename)
    errors = []

    CSV.read(filename).each_with_index do |row, index|
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

          order = Order.create!(order_hash.merge(origin: origin, destination: destination, reverse: reverse))
        end
      rescue Exception => e
        errors << ["row: #{index}", e.message]
      end
    end
    errors
  end

end
