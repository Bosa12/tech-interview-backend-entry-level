class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product, optional: true
  validates :quantity, numericality: { greater_than: 0 }

  def total_price
    quantity * product_unit_price
  end

  def product_unit_price
    Cart::MOCK_PRODUCTS[product_id.to_s][:unit_price]
  end

  def product_name
    Cart::MOCK_PRODUCTS[product_id.to_s][:name]
  end

  def to_json_response
    {
      id: product_id,
      name: product_name,
      quantity: quantity,
      unit_price: product_unit_price.round(2),
      total_price: total_price.round(2)
    }
  end
end
