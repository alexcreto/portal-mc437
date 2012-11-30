class AddStatusToPedido < ActiveRecord::Migration
  def change
    add_column :pedidos, :status, :string
  end
end
