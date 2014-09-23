# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

User.create(name: "JorisBROLL", email: "jorisbroll@admin.com", password: "aaaaaa", password_confirmation: "aaaaaa", account_type: "admin")
User.create(name: "MaelALOS", email: "maelalos@admin.com", password: "aaaaaa", password_confirmation: "aaaaaa", account_type: "admin")