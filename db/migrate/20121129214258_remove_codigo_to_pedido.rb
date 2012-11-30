class RemoveCodigoToPedido < ActiveRecord::Migration
  def up
    remove_column :pedidos, :codigo
  end

  def down
    add_column :pedidos, :codigo, :integer
  end
end
