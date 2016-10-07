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

user_ids = User.all.pluck(:id)

for e in 1..5 do
  Event.create(
    topic: "如果我們是學生",
    start_time: 7.days.ago,
    end_time: 7.days.since,
    location: ["台中市", "台北市"][rand(0..1)],
    content: "他的聲音變弱，我爸在也在醫科教書，生活花費比較便宜，很棒同時也是很悲傷的事情是，我在2011年春天被調去上海前曾在這裡住過一年，突然間，如果我們是學生，我們在亞洲教育中被教導的許多重大選擇，看看左側的夜景和右邊的老建築和銀行。請粉絲們持續留意各項報導，怎麼就是有人那麼再意臉書上寫什麼...以為幫別人求婚，林說，嘖嘖~，然而被騷擾的不悅感與日俱增，最愛女人露哪裡，漁業署今發出新聞稿表示，林義雄將禁食。",
    user_id: user_ids[rand(0 .. user_ids.size - 1)]
  )
end