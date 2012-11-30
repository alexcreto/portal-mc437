class Pedido < ActiveRecord::Base
  attr_accessible :codigo, :cpf, :entrega, :pedidos, :status, :produto1, :qnt1, :produto2, :qnt2, :produto3, :qnt3, :produto4, :qnt4
end
