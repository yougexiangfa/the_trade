class Trade::My::CartItemsController < Trade::My::BaseController
  before_action :set_cart_item, only: [:update, :destroy]
  before_action :set_additions

  def index
    @cart_items = current_cart.pending
    @checked_ids = @cart_items.checked.pluck(:id)
  end

  def create
    cart_item = current_cart.where(good_id: params[:good_id], good_type: params[:good_type]).first
    params[:quantity] ||= 1
    if cart_item.present?
      cart_item.quantity = cart_item.quantity + params[:quantity].to_i
      cart_item.status = 'pending'
      cart_item.myself = false
      cart_item.save
    else
      cart_item = @cart_items.build(good_id: params[:good_id], good_type: params[:good_type], quantity: params[:quantity], status: 'pending', myself: true)
      cart_item.save
    end

    @checked_ids = @cart_items.checked.pluck(:id)

    render 'index'
  end

  def total
    if params[:add_id].present?
      @add = current_cart.find_by(id: params[:add_id])
      @add.update(checked: true)
    elsif params[:remove_id].present?
      @remove = current_cart.find_by(id: params[:remove_id])
      @remove.update(checked: false)
    end
  end

  def update
    @cart_item.update(quantity: params[:quantity])
  end

  def destroy
    @cart_item.update(status: :deleted, checked: false)
  end

  private
  def set_cart_item
    @cart_item = current_cart.find(params[:id])
  end

  def set_additions
    if current_buyer
      @additions = CartItem.checked_items(buyer_type: current_buyer.type, buyer_id: current_buyer.id, myself: true)
    else
      @additions = CartItem.checked_items(session_id: session.id, myself: true)
    end
  end

  def cart_item_params
    params.require(:cart_item).permit(
      id: [],
      single_price: [],
      amount: [],
      total_price: []
    )
  end

  def current_cart
    if current_buyer
      @cart_items = current_buyer.cart_items
    else
      @cart_items = CartItem.where(session_id: session.id)
    end
  end

end
