class Item < ActiveRecord::Base
  attr_accessible :description, :image_url, :preco, :title
end
