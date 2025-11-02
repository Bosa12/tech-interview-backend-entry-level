FactoryBot.define do
  factory :cart_item do
    association :cart
    product_id { 1230 }
    quantity { 1 }
  end
end
