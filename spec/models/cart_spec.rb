require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:cart_abandonado) { create(:cart, abandoned_at: 7.days.ago) }

  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than 0")
    end
  end
describe '#mark_as_abandoned' do
  # Simula um carrinho que não é atualizado há 8 dias (usando a coluna do Rails)
  let(:cart) { create(:cart, abandoned_at: nil, updated_at: 8.days.ago) }

  it 'marks the shopping cart as abandoned if inactive for a certain time' do
    expect { cart.mark_as_abandoned }.to change { cart.abandoned_at.present? }.from(false).to(true)
  end
end

describe '#remove_if_abandoned' do
  # Cria um carrinho que foi interagido pela última vez há 8 dias (updated_at)
  let(:cart) { create(:cart, updated_at: 8.days.ago) }

  # Remova a linha 'before { cart.mark_as_abandoned }'

  it 'removes the shopping cart if abandoned for a certain time' do
    # 1. Simula que o Job marcou o carrinho como ABANDONADO no passado:
    # O método deve ter sido executado para marcar o carrinho.
    # Se você está testando a REMOÇÃO, você precisa simular que a MARCAÇÃO aconteceu.

    # Se você for testar o método remove_if_abandoned, ele espera que o campo abandoned_at esteja preenchido.

    # Fazemos a marcação (mark_as_abandoned)
    cart.mark_as_abandoned

    # Corrigimos o timestamp para 8 dias atrás (simulando que a marcação aconteceu há 8 dias)
    cart.update_column(:abandoned_at, 8.days.ago)

    # 2. Testa a remoção:
    expect { cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
  end
end
end
