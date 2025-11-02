FactoryBot.define do
  factory :cart do
    last_interaction_at { Time.current }

    after(:create) do |cart|
      create(:cart_item, cart: cart, quantity: 1, product_id: 1230)
    end
  end
end
