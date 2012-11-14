class SiteLogger
  attr_reader :logged
  
  def initialize
    @logged=false
  end
  
  def login cpf, senha
    result=Nestful.json_get "http://staff03.lab.ic.unicamp.br:8888/authentications/loga.json?login=#{cpf}&senha=#{senha}"
    @logged= result[:response] != 0
    return @logged
  end
  
  def is_logged_in
    return @logged
  end
  
  def log_off cpf, senha
    result=Nestful.json_get "http://staff03.lab.ic.unicamp.br:8888/authentications/desloga.json?login=#{cpf}&senha=#{senha}"
    @logged= result[:response] == 0 || @logged
    return @logged
  end
  
end

class Address
  attr_reader :valid
  attr_reader :cep, :uf, :cidade, :bairro, :tipo_logradouro , :logradouro
  
  def initialize
    @client=Savon.client "http://g2mc437.heliohost.org/parte2/service/webserver.php?wsdl"
    @valid=false
  end
  
  def update_by_cep cep
    body = Hash.new
    body[:cep] = cep
    result = @client.request :g02_busca_por_cep , :body => body
    
    result=result.to_hash[:g02_busca_por_cep_response]

    unless result.nil?
      
      @cep=cep
      @numero=result[:numero]
      @uf=result[:uf]
      @cidade=result[:cidade]
      @bairro=result[:bairro]
      @tipo_logradouro=result[:tipo]
      @logradouro=result[:logradouro]
      @valid = true
      
      return true
    end
    
    @valid = false
    return false
  end

  
end

class Client
  attr_reader :nome, :cpf, :senha, :endereco, :numero
  attr_writer :logger
  
  def initialize
    @logger=SiteLogger.new
    @endereco=Address.new
  end
  
  #loga o usuário
  def login cpf, senha
    
    if @logger.login cpf, senha
      @senha=senha
      @cpf=cpf
      
      update_all
      return true
    end
  
    return false
  end
  
  #desloga o usuário
  def logout
    if @logger.log_off @cpf, @senha
      return true
    end
    return false
  end
  
  #atualiza cep numero e nome do cliente
  def update_basic_info
    exists = Nestful.json_get "http://mc437.herokuapp.com/existe/#{@cpf}.json"
    
    if exists["existe"] == 1
      result = Nestful.json_get "http://mc437.herokuapp.com/tudo/#{@cpf}.json"
    else
      return false
    end
    
    
    if result != nil
      @cep = result["cep"]
      @numero = result["numero"]
      @nome = result["nome"]
      return true
    end
    
    return false
  end
  
  #atualiza endereco
  def update_address
    if @endereco.update_by_cep @cep
      return true
    end
    return false
  end

  #atualiza todos os dados do usuario
  def update_all
    
    if ! update_basic_info
      return false
    end
    
    if ! update_address
      return false
    end
    
    return true
  end
  
end


#Basicamente serve pra procurar produtos com método search
class Products
  attr_writer :client_desc
  attr_reader :client_desc
  
  def initialize
    @client_desc=Savon.client("http://staff01.lab.ic.unicamp.br:8080/ProdUNICAMPServices/services/Servicos?wsdl")
    
  end
  
  #Pesquisa por produtos
  def search categoria, nome
    body = Hash.new
    
    unless categoria.nil?
      body[:categoria] = categoria
    end
    
    unless nome.nil?
      body[:nome] = nome
    end
    
    result_desc = @client_desc.request :GetListProdutoByFilter , :body => body
    prods = []
    unless result_desc.nil?
      data=result_desc.to_hash[:get_list_produto_by_filter_response][:return]
      unless data.kind_of?(Array)
        data=[data]
      end
      
      data.each do |p|
        r= Nestful.json_get "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/#{p[:codigo]}.json"
        prods << Product.new(p[:codigo],p[:categoria],p[:nome],r["product"]["price"],p[:descricao],r["product"]["quantity"]) 
      end
    end
   
    
    return prods
  end

end


class Product
  attr_writer  :codigo, :categoria, :nome, :preco, :descricao, :quantidade

  ##depois se precisar colocamos mais atributos, esses são os mais importantes
  def initialize codigo, categoria, nome, preco, descricao, quantidade
    
    @categoria = categoria
    @nome = nome
    @preco = preco
    @descricao = descricao
    @quantidade = quantidade

  end
  
end
