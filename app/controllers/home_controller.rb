require "app/models/models.rb"
require "pp"


class HomeController < ApplicationController
  attr_reader :client
  
  def initialize
    @client=Client.new
  end
  
  def login
    @client.login(params[:cpf], params[:senha])
    if @client.logger.logged
      session[:client] = Array.new
      session[:client] << @client.nome
      session[:client] << @client.cpf
      pp session[:client]
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
    client = Savon.client "http://staff01.lab.ic.unicamp.br:8480/ModuloValidacaoCreditoWS/services/ValidacaoCreditoService?wsdl"
    score = client.request :getScore, :body => { :cpf => session[:client].last, :token => "0123456789"}
    @score = score.to_hash[:get_score_response][:return][:score]
  end

  def success
    total = 0
    cart = session[:cart] ||= {}
    itens = Products.new.search nil, nil 
    cart.each do | id, quantidade | 
     
      itens.each do | item | 
        if item.codigo == id 
          Nestful.put "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/quantity.json", :format => :json, :params => {:code => id, :quantity => quantidade*-1}
        

        total += quantidade * item.preco 
        end
      end
    end
    cart = {}

    banco = Savon.client "http://mc437-2012s2-banco-ws.pagodabox.com/ws/BancoApi?wsdl"
    
    body = Hash.new
    body["cnpj_contrato_convenio"] = "44.867.477/0001-44"
    body[:token] = "54d45bc31c9f63c37b0108e615cb9077"
    body[:cliente] = session[:client].first
    body[:valor] = total

    banco.request :emitir_boleto, :body => body
  


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

  def cartao
	client = Savon.client "http://www.chainreactor.net/services/nusoap/WebServer.php?wsdl"
	valid = client.request :validateTransaction, :body => { :value => "100", :token => "1", :number => "344259359401285"}
	@valid = valid.to_hash[:validate_transaction_response][:return]
  end

end
