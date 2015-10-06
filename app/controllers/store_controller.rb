class StoreController < ApplicationController
  include CurrentCart
  before_action :set_cart
  def index
    @products = Product.order(:title)
    session[:counter] ||= 0
    session[:counter] += 1
    @count = session[:counter]
  end
end
