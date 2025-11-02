class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  validate :total_price_must_be_positive

  MOCK_PRODUCTS = {
    1230 => { name: "Nome do produto X", unit_price: 7.00 },
    345  => { name: "Nome do produto Y", unit_price: 1.99 },
    645  => { name: "Nome do produto Z", unit_price: 3.50 },
  }.with_indifferent_access

  def mark_as_abandoned
    return unless inactive_for_too_long?
    update!(abandoned_at: Time.current)
  end

  def inactive_for_too_long?
    last_interaction_at.present? && last_interaction_at < 7.days.ago
  end

  def abandoned?
    abandoned_at.present?
  end

  def remove_if_abandoned
    destroy if abandoned?
  end

  def add_or_update_product(product_id:, quantity:)
    raise ArgumentError, "A quantidade deve ser positiva." if quantity <= 0

    item = cart_items.find_by(product_id: product_id)
    if item
      item.quantity += quantity  # soma em vez de sobrescrever
      item.save!
    else
      cart_items.create!(product_id: product_id, quantity: quantity)
    end
    touch
  end

  def remove_product(product_id)
    item = cart_items.find_by(product_id: product_id)
    raise ActiveRecord::RecordNotFound, "Produto não encontrado no carrinho." unless item

    item.destroy
    touch
  end

  def to_json_response
    products_payload = cart_items.map(&:to_json_response)

    {
      id: id,
      products: products_payload,
      total_price: products_payload.sum { |p| p[:total_price] }.round(2)
    }
  end

  def total_price
    cart_items.sum { |ci| ci.total_price.to_f }
  end

  private

  def total_price_must_be_positive
    if total_price.to_f <= 0
      errors.add(:total_price, 'must be greater than 0')
    end
  end
end
