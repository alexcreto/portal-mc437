class Home < ActiveRecord::Base
  # attr_accessible :title, :body

  def self.get_json
    code = 3333
    uri = "http://g1:g1@mc437-g8-estoque-v2.webbyapp.com/products/currentInfo/" + code.to_s + ".json"
    rest = Nestful.json_get uri
  end

end
