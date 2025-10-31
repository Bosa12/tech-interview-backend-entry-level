FactoryBot.define do
  factory :cart do
    abandoned_at { nil } # Padrão: não abandonado
  end

  factory :abandoned_cart, parent: :cart do
    abandoned_at { 8.days.ago } 
  end
end
