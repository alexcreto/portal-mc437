class Pedido < ActiveRecord::Base
  attr_accessible :codigo, :cpf, :entrega, :pedidos, :status
end
