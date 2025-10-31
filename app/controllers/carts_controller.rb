  # app/controllers/carts_controller.rb
class CartsController < ApplicationController
  before_action :set_cart

  def add_product
    @cart.add_or_update_product(
      product_id: params[:product_id],
      quantity: params[:quantity].to_i
    )
    render json: @cart.to_json_response, status: :created
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    render json: @cart.to_json_response, status: :ok
  end

  def update_quantity
    @cart.add_or_update_product(
      product_id: params[:product_id],
      quantity: params[:quantity].to_i
    )
    render json: @cart.to_json_response, status: :ok
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Produto não encontrado ou inválido" }, status: :not_found
  end

  def remove_product
    @cart.remove_product(params[:product_id])
    render json: @cart.to_json_response, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  private

  def set_cart
    if session[:cart_id].present?
      @cart = Cart.find_by(id: session[:cart_id])
    end

    unless @cart
      @cart = Cart.create!
      session[:cart_id] = @cart.id 
    end
  end
end
