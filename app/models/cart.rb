class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  validate :total_price_must_be_positive

  MOCK_PRODUCTS = {
    1230 => { name: "Nome do produto X", unit_price: 7.00 },
    345  => { name: "Nome do produto Y", unit_price: 1.99 },
    645  => { name: "Nome do produto Z", unit_price: 3.50 },
  }.with_indifferent_access




  def add_or_update_product(product_id:, quantity:)
    raise ArgumentError, "A quantidade deve ser positiva." if quantity <= 0

    item = cart_items.find_by(product_id: product_id)
    if item
      item.quantity = quantity
      item.save!
    else
      cart_items.create!(product_id: product_id, quantity: quantity)
    end
    touch
  end

  def remove_product(product_id)
    item = cart_items.find_by(product_id: product_id)
    unless item
      raise ActiveRecord::RecordNotFound, "Produto não encontrado no carrinho."
    end
    item.destroy
    touch
  end

  def to_json_response
    products_payload = cart_items.map do |item|
      item_data = item.to_json_response
      item_data
    end

    {
      id: self.id,
      products: products_payload,
      total_price: products_payload.sum { |p| p[:total_price] }.round(2)
    }
  end

   def total_price
    cart_items.to_a.sum { |ci| ci.total_price.to_f }
   end

  private

  def total_price_must_be_positive
    unless total_price.to_f > 0
      errors.add(:total_price, 'must be greater than 0')
    end
  end
end
