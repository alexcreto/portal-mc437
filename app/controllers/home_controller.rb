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

    #prod_info = Savon.client "http://staff01.lab.ic.unicamp.br:8080/ProdUNICAMPServices/services/Servicos?wsdl"
    #prod_info.wsdl.soap_actions
    #@info1 = prod_info.request :get_???, :body => { :codigo => "1010" }
  end

  def add_item(code)
    Nestful.post "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/quantity.json", :format => :json, :params => {:code => code, :quantity => 1}
    redirect_to :back
  end

  def sub_item(code)
    Nestful.post "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/quantity.json", :format => :json, :params => {:code => code, :quantity => -1}
    redirect_to :back
  end

  def products

  end

  def payment
    
  end

  

end
