class AddCodigoToPedido < ActiveRecord::Migration
  def change
    add_column :pedidos, :codigo, :string
  end
end
