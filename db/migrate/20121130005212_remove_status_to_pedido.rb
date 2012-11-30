class RemoveStatusToPedido < ActiveRecord::Migration
  def up
    remove_column :pedidos, :status
  end

  def down
    add_column :pedidos, :status, :integer
  end
end
