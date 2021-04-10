FactoryBot.define do
  factory :message do
    receiver_id { 1 }
    content { "MyText" }
    read_status { 1 }
    request { nil }
    user { nil }
  end
end
