class HomeController < ApplicationController

  def login
    
  end

  def index
    @prod1 = Nestful.json_get "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/1010.json"
    @prod2 = Nestful.json_get "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/2222.json"
    @prod3 = Nestful.json_get "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/3030.json"
    @prod4 = Nestful.json_get "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/3034.json"
    @prod5 = Nestful.json_get "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/3234.json"
    @prod6 = Nestful.json_get "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/3333.json"
  end

  def products

  end

  def payment
    
  end

  

end
