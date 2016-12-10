# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Currency.create(change: 1.64)

User.create(name: 'admin', email: 'admin@ezicargo.com', password: 'ezi654321', role: 'admin')
User.create(name: 'user', email: 'user@ezicargo.com', password: 'user654321', role: 'user')
