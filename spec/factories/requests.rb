FactoryBot.define do
  factory :request do
    title { "MyString" }
    need { "MyString" }
    description { "MyText" }
    lat { 1.5 }
    lng { 1.5 }
    address { "MyString" }
    status { 1 }
  end
end
