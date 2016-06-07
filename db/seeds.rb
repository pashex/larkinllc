# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(email: 'dispatcher@larkinllc.com', password: '1234', role: 'dispatcher')
User.create!(email: 'driver1@larkinllc.com', password: '1234', role: 'driver')
User.create!(email: 'driver2@larkinllc.com', password: '1234', role: 'driver')

