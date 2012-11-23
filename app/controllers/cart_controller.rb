class CartController < ApplicationController

  def add
    id = params[:id]
    cart = session[:cart] ||= {}
    cart[id] = (cart[id] || 0) + 1
        
    redirect_to :action => :index
  end

  def index
    @cart = session[:cart] || {}
  end
  
  def change

    r= Nestful.json_get "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/#{params[:id]}.json"
    if params[:quantity].to_i > r["product"]["quantity"]
      flash[:notice] = "Você pediu mais produtos do que existem em estoque"
      redirect_to :action => :index and return false
    end

    cart = session[:cart]
    id = params[:id];
    quantity = params[:quantity].to_i
    if cart and cart[id]
      unless quantity <= 0
        cart[id] = quantity
      else
        cart.delete id
      end
    end
    redirect_to :action => :index
  end

end
