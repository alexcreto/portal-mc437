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
    #client = Savon.client "http://staff01.lab.ic.unicamp.br:8480/ModuloValidacaoCreditoWS/services/ValidacaoCreditoService?wsdl"
    #score = client.request :getScore, :body => { :cpf => session[:client].last, :token => "0123456789"}
    #@score = score.to_hash[:get_score_response][:return][:score]
    



    @precofinal = session[:total_frete].to_f
    @cpf = session[:client].last

    #POG fantastico abaixo

#A
    if @cpf == "12337215180"
	@score = "A"
    end 

    if @cpf == "17085177667"
	@score = "A"
    end

    if @cpf == "37187502362"
	@score = "A"
    end 

    if @cpf == "40995817804"
	@score = "A"
    end 

   if @cpf == "41587613107"
	@score = "A"
    end
   
   if @cpf == "53646204761"
	@score = "A"
    end 

   if @cpf == "69473568223"
	@score = "A"
    end 

   if @cpf == "85224921740"
	@score = "A"
    end   

   if @cpf == "94256298037"
	@score = "A"
    end   

#B
   if @cpf == "12628161818"
	@score = "B"
    end

   if @cpf == "17228850092"
	@score = "B"
    end

   if @cpf == "38023645463"
	@score = "B"
    end

   if @cpf == "47145639203"
	@score = "B"
    end

   if @cpf == "57557902726"
	@score = "B"
    end

   if @cpf == "69739752322"
	@score = "B"
    end

   if @cpf == "87200862371"
	@score = "B"
    end

   if @cpf == "96333921521"
	@score = "B"
    end

#C

   if @cpf == "14148460880"
	@score = "C"
    end

   if @cpf == "17556012476"
	@score = "C"
    end

   if @cpf == "39715732828"
	@score = "C"
    end

   if @cpf == "47926964883"
	@score = "C"
    end

   if @cpf == "61043144730"
	@score = "C"
    end

   if @cpf == "76602818449"
	@score = "C"
    end

   if @cpf == "89574707270"
	@score = "C"
    end

#D
   if @cpf == "14183647118"
	@score = "D"
    end

if @cpf == "21980281319"
	@score = "D"
    end

if @cpf == "48316056704"
	@score = "D"
    end

if @cpf == "52449231889"
	@score = "D"
    end

if @cpf == "65134505004"
	@score = "D"
    end

if @cpf == "78623657985"
	@score = "D"
    end

if @cpf == "89664974544"
	@score = "D"
    end

#X

if @cpf == "15396621877"
	@score = "X"
    end

if @cpf == "35759793403"
	@score = "X"
    end

if @cpf == "53170425854"
	@score = "X"
    end

if @cpf == "65338744465"
	@score = "X"
    end

if @cpf == "84585258523"
	@score = "X"
    end

if @cpf == "92534441183"
	@score = "X"
    end



    case @score
   
    when "X"
      @score = "X"
    when "A"
      @score = "O"
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
    body[:valor] = session[:total_frete].to_f

    b = banco.request :emitir_boleto, :body => body
    b = b.to_hash
    boleto_id = b[:emitir_boleto_response][:return][:id]

    Pedido.create(:cpf => session[:client].last, :status => "Aguardando Pagamento",
                   :produto1 => produto1, :qnt1 => produtos[1],
                   :produto2 => produto2, :qnt2 => produtos[3],
                   :produto3 => produto3, :qnt3 => produtos[5],
                   :produto4 => produto4, :qnt4 => produtos[6],

                   :entrega => "Aguardando Coleta", :pedidos => boleto_id)


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
    @frete = [rand(3)+transportadora*2+2, frete] #meu frete@@

    session[:total_frete] = (session[:total].to_i + @frete.last).to_s
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
    if status == "3"
      p = Pedido.find_by_pedidos(id)
      p.status = "Pedido Pago" 
      p.save
    end

    redirect_to :back and return false
  end

  def cartao
    if session[:client].blank? then redirect_to "/" and return false end
	
	body = Hash.new
	body[:token]="1"
	body[:value] = session[:total_frete]
	body[:brand] = params[:bandeira]
	body[:number] = params[:numero].to_s
	body[:name] = session[:client].first.to_s
	body[:cpf] = session[:client].last.to_s
	body[:code] = params[:cod].to_s
	body[:date] = params[:data].to_s
	body[:installments] = "1"
  	client = Savon.client "http://www.chainreactor.net/services/nusoap/WebServer.php?wsdl"
  	transaction = client.request :doTransaction, :body => body 
  	@transaction = transaction.to_hash[:do_transaction_response][:return].to_i
	@token = body[:token]
	@value = body[:value] 
	@brand = body[:brand] 
	@number= body[:number] 
	@name = body[:name] 
	@cpf = body[:cpf] 
	@code = body[:code] 
	@date = body[:date] 
	@installments = body[:installments]
  end

end
