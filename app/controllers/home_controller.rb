require "app/models/MagicUtilities.rb"
require "pp"


class HomeController < ApplicationController
  attr_reader :client
  
  def initialize
    @client=Client.new
  end
  
  def login
    @client.login(params[:cpf], params[:senha])
    if @client.logger.logged
      redirect_to "/index" and return false
    else
      unless params[:cpf].blank? && params[:senha].blank?
        flash.now[:notice] = "CPF ou senha inválida"
      end
    end
  end

  def index
    if params[:name].blank?
      @produtos = Products.new.search nil, nil
    else
      @produtos = Products.new.search nil, params[:name]
    end
    
    
    respond_to do |format|
      format.html
      format.json{ render :json => @produtos }
    end
  end

  def add_item
    Nestful.put "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/quantity.json", :format => :json, :params => {:code => params[:code], :quantity => 1}
    redirect_to :back
  end

  def sub_item
    Nestful.put "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/quantity.json", :format => :json, :params => {:code => params[:code], :quantity => -1}
    redirect_to :back
  end

  def product_description
    code = params[:code]
    client = Savon.client "http://staff01.lab.ic.unicamp.br:8080/ProdUNICAMPServices/services/Servicos?wsdl"
    @address = client.request :get_produto_by_codigo, :body => { :codigo => "#{code}"}
  end

  def payment
    
  end

  def address
    cep = params[:cep]
    client = Savon.client "http://g2mc437.heliohost.org/parte2/service/webserver.php?wsdl"
    @address = client.request :g02_busca_por_cep, :body => { :cep => "#{cep}"}
  end
  
  def cart
    
  end

  def customer_support
    
  end

end
