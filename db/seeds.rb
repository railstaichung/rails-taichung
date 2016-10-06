# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# puts "這個種子檔會自動建立5個帳號, 每個帳號創建 4 個 profile links"

create_accounts =for h in 1..5 do
                  User.create([email: "#{h}@#{h}", password: "123456", password_confirmation: "123456", name: "測試用帳號#{h}"])
                end
create_profiles = for i in 1..5 do
                 for k in 1..4 do
                   Profile.create([content: "連結 #{k} ", user_id: "#{i}"])
                 end
                end
