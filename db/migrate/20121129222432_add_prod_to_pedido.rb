class AddProdToPedido < ActiveRecord::Migration
  def change
    add_column :pedidos, :produto1, :string
    add_column :pedidos, :qnt1, :integer
    add_column :pedidos, :produto2, :string
    add_column :pedidos, :qnt2, :integer
    add_column :pedidos, :produto3, :string
    add_column :pedidos, :qnt3, :integer
    add_column :pedidos, :produto4, :string
    add_column :pedidos, :qnt4, :integer
  end
end
