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
    session.delete :client
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
    if session[:client].blank? then redirect_to "/" and return false end
    client = Savon.client "http://staff01.lab.ic.unicamp.br:8480/ModuloValidacaoCreditoWS/services/ValidacaoCreditoService?wsdl"
    score = client.request :getScore, :body => { :cpf => session[:client].last, :token => "0123456789"}
    @score = score.to_hash[:get_score_response][:return][:score]
    
    @precofinal = session[:total]

    case @score
    when "x"
      @score = "X"
    when "X"
      @score = "X"
    when "A"
      @score = "O"
    when "a"
      @score = "O"
    when "b"
      if @precofinal < 2000.00
        @score = "O"
      end
    when "c"
      if @precofinal < 1000.00
        @score = "O"
      end
    when "d"
      if @precofinal < 500.00
        @score = "O"
      end
    when "B"
      if @precofinal < 2000.00
        @score = "O"
      end
    when "C"
      if @precofinal < 1000.00
        @score = "O"
      end
    when "D"
      if @precofinal < 500.00
        @score = "O"
      end
    end
  end

  def boleto
    if session[:client].blank? then redirect_to "/" and return false end
    produtos = Array.new
    prod = Array.new
    session[:cart].map {|c| produtos << prod = [c[0].to_i, c[1]]}

    post_body = Hash.new
    post_body["id_portal"] = 1
    post_body["cep_remetente"] = 97574220
    post_body["cep_destinatario"] = session[:cep].to_i
    post_body["id_transportadora"] = session[:trans]
    post_body[:produtos] = produtos

    #post = Savon.client "http://staff01.lab.ic.unicamp.br/grupo9/webservice/ws.php?wsdl"
    #cod_post = post.request :cadastrar_entrega, :body => post_body

    produtos = produtos.flatten

    produto2 = nil
    produto3 = nil
    produto4 = nil
    qnt1 = produtos[1] ||= nil
    qnt2 = produtos[3] ||= nil
    qnt3 = produtos[5] ||= nil
    qnt4 = produtos[7] ||= nil

    client = Savon.client "http://staff01.lab.ic.unicamp.br:8080/ProdUNICAMPServices/services/Servicos?wsdl"
    description = client.request :get_produto_by_codigo, :body => { :codigo => "#{produtos[0]}"}
    produto1 = description.to_hash[:get_produto_by_codigo_response][:return][:nome]
    unless produtos[2].blank?
      description = client.request :get_produto_by_codigo, :body => { :codigo => "#{produtos[2]}"}
      produto2 = description.to_hash[:get_produto_by_codigo_response][:return][:nome]
      unless produtos[4].blank?
        description = client.request :get_produto_by_codigo, :body => { :codigo => "#{produtos[4]}"}
        produto3 = description.to_hash[:get_produto_by_codigo_response][:return][:nome]
        unless produtos[6].blank?
          description = client.request :get_produto_by_codigo, :body => { :codigo => "#{produtos[6]}"}
          produto4 = description.to_hash[:get_produto_by_codigo_response][:return][:nome]
        end
      end
    end


    Pedido.create(:cpf => session[:client].last, :status => "Aguardando Pagamento",
                   :produto1 => produto1, :qnt1 => produtos[1],
                   :produto2 => produto2, :qnt2 => produtos[3],
                   :produto3 => produto3, :qnt3 => produtos[5],
                   :produto4 => produto4, :qnt4 => produtos[6],

                   :entrega => "Aguardando Coleta", :pedidos => session[:boleto])

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

    b = banco.request :emitir_boleto, :body => body
    b = b.to_hash
    session[:boleto] = b[:emitir_boleto_response][:return][:id]

  end

  def entrega
    if session[:client].blank? then redirect_to "/" and return false end
    result = Nestful.json_get "http://mc437.herokuapp.com/tudo/#{session[:client].last}.json"
    session[:cep] = result["cep"]
    client = Savon.client "http://g2mc437.heliohost.org/parte2/service/webserver.php?wsdl"
    address = client.request :g02_busca_por_cep, :body => { :cep => "#{result["cep"]}"}
    @address = address.to_hash
    @numero = result["numero"]
  end

  def entregaalt
    if session[:client].blank? then redirect_to "/" and return false end
    session[:cep] = params[:cep]
    client = Savon.client "http://g2mc437.heliohost.org/parte2/service/webserver.php?wsdl"
    address = client.request :g02_busca_por_cep, :body => { :cep => params[:cep] }
    @address = address.to_hash
    @numero = params[:number]
  end

  def frete
    if session[:client].blank? then redirect_to "/" and return false end
    produtos = Array.new
    #session[:cart].map {|c| produtos << [c[0].to_i, c[1]]}    
    cep = session[:cep]
    transportadora = params[:servico]
    session[:trans] = transportadora
    client = Savon.client "http://staff01.lab.ic.unicamp.br/grupo9/webservice/ws.php?wsdl"
    #trans = client.request :calcula_frete_e_prazo, :body => { :cep_remetente => 97574220, :cep_destinatario => cep, :id_transportadora => transportadora, :produtos => produtos }
    #@frete = [trans.to_hash[:calcula_frete_e_prazo_response][:return][:prazo], trans.to_hash[:calcula_frete_e_prazo_response][:return][:frete]]
    

    frete = 0 #meu frete@@
    session[:cart].map {|c| frete += (rand(3)+13) * c[1]} #meu frete@@
    transportadora = transportadora.to_i + 1 #meu frete@@
    transportadora = transportadora % 4 #meu frete@@
    @frete = [rand(3)+transportadora*2, frete] #meu frete@@
  end

  def transporte
    if session[:client].blank? then redirect_to "/" and return false end
    
  end
  
  def meuspedidos
    if session[:client].blank? then redirect_to "/" and return false end
    @pedidos = Pedido.find_all_by_cpf(session[:client].last)
  end

  def cart
    if session[:client].blank? then redirect_to "/" and return false end
    
  end

  def customer_support
    
  end

  def atualizar

    id = Pedido.find(params[:id]).pedidos

    banco = Savon.client "http://mc437-2012s2-banco-ws.pagodabox.com/ws/BancoApi?wsdl"
    
    body = Hash.new
    body["cnpj_contrato_convenio"] = "44.867.477/0001-44"
    body[:token] = "54d45bc31c9f63c37b0108e615cb9077"
    body[:cliente] = session[:client].first
    body[:id] = id

    b = banco.request :obter_boleto, :body => body
    b = b.to_hash

    status = b[:obter_boleto_response][:return][:estado]
    if status == 3 then Pedido.find_by_pedidos(id).status = "Pedido Pago" end

    redirect_to :back and return false
  end

  def cartao
    if session[:client].blank? then redirect_to "/" and return false end
	
	body = Hash.new
	body[:token]="1"
	body[:value] = "270.50"
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
