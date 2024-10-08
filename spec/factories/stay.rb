FactoryBot.define do
  factory :stay do
    start_date { Date.new(2024, 1, 15) }
    end_date { Date.new(2024, 1, 20) }
    association :studio
  end
end
