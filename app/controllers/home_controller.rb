require "app/models/models.rb"
require "pp"


class HomeController < ApplicationController
  attr_reader :client
  
  def initialize
    @client=Client.new
  end
  
  def login
    #reset_session
    #pp session
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
    if params[:name].blank? && params[:category].blank?
      @produtos = Products.new.search nil, nil
    else
      @produtos = Products.new.search params[:category], params[:name]
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

  def product_description
    code = params[:code]
    client = Savon.client "http://staff01.lab.ic.unicamp.br:8080/ProdUNICAMPServices/services/Servicos?wsdl"
    @address = client.request :get_produto_by_codigo, :body => { :codigo => "#{code}"}
  end

  def payment
    client = Savon.client "http://staff01.lab.ic.unicamp.br:8480/ModuloValidacaoCreditoWS/services/ValidacaoCreditoService?wsdl"
    score = client.request :getScore, :body => { :cpf => session[:client].last, :token => "0123456789"}
    @score = score.to_hash[:get_score_response][:return][:score]
    
    @precofinal = session[:total]

    case @score
    when "A"
      @score = "O"
    when "B"
      if session[:total] < 2000
        @score = "O"
      end
    when "C"
      if session[:total] < 1000
        @score = "O"
      end
    when "D"
      if session[:total] < 500
        @score = "O"
      end
    end
  end

  def boleto
    produtos = Array.new
    prod = Array.new
    session[:cart].map {|c| produtos << prod = [c[0].to_i, c[1]]}

    post_body = Hash.new
    post_body[:id_portal] = 1
    post_body[:cep_remetente] = 05055010
    post_body[:cep_destinatario] = session[:cep]
    post_body[:id_transportadora] = session[:trans]
    post_body[:produtos] = produtos

    post = Savon.client "http://staff01.lab.ic.unicamp.br/grupo9/webservice/ws.php?wsdl"
    cod_post = post.request :cadastrar_entrega, :body => post_body

    Pedido.create(:cpf => session[:client].last, :status => 0, :pedidos => produtos, :entrega => "Aguardando Coleta", :codigo => cod_post)

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
    session.delete :cart

    banco = Savon.client "http://mc437-2012s2-banco-ws.pagodabox.com/ws/BancoApi?wsdl"
    
    body = Hash.new
    body["cnpj_contrato_convenio"] = "44.867.477/0001-44"
    body[:token] = "54d45bc31c9f63c37b0108e615cb9077"
    body[:cliente] = session[:client].first
    body[:valor] = total

    banco.request :emitir_boleto, :body => body

  end

  def entrega
    result = Nestful.json_get "http://mc437.herokuapp.com/tudo/#{session[:client].last}.json"
    session[:cep] = result["cep"]
    client = Savon.client "http://g2mc437.heliohost.org/parte2/service/webserver.php?wsdl"
    address = client.request :g02_busca_por_cep, :body => { :cep => "#{result["cep"]}"}
    @address = address.to_hash
    @numero = result["numero"]
  end

  def entregaalt
    session[:cep] = params[:cep]
    client = Savon.client "http://g2mc437.heliohost.org/parte2/service/webserver.php?wsdl"
    address = client.request :g02_busca_por_cep, :body => { :cep => params[:cep] }
    @address = address.to_hash
    @numero = params[:number]
  end

  def frete
    produtos = Array.new
    session[:cart].map {|c| produtos << [c[0].to_i, c[1]]}
    pp produtos
    cep = session[:cep]
    transportadora = params[:servico]
    session[:trans] = transportadora
    client = Savon.client "http://staff01.lab.ic.unicamp.br/grupo9/webservice/ws.php?wsdl"
    trans = client.request :calcula_frete_e_prazo, :body => { :cep_remetente => 05055010, :cep_destinatario => cep, :id_transportadora => transportadora, :produtos => produtos }
    @frete = [trans.to_hash[:calcula_frete_e_prazo_response][:return][:prazo], trans.to_hash[:calcula_frete_e_prazo_response][:return][:frete]]
  end

  def transporte
    
  end
  
  def cart
    
  end

  def customer_support
    
  end

  def cartao
	
	body = Hash.new
	body[:token]="10"
	body[:value] = "1000"
	body[:brand] = params[:bandeira]
	body[:number] = params[:numero].to_s
	body[:name] = session[:client].first.to_s
	body[:cpf] = session[:client].last.to_s
	body[:code] = params[:cod].to_s
	body[:date] = params[:data].to_s
	body[:installments] = "1"
  	client = Savon.client "http://www.chainreactor.net/services/nusoap/WebServer.php?wsdl"
  	transaction = client.request :doTransaction, :body => body 
  	@transaction = transaction.to_hash
	@BODY = body
  end

end
