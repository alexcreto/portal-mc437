class CreatePedidos < ActiveRecord::Migration
  def change
    create_table :pedidos do |t|
      t.string :cpf
      t.integer :status
      t.integer :pedidos
      t.string :entrega
      t.integer :codigo

      t.timestamps
    end
  end
end
