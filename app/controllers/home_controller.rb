class HomeController < ApplicationController

  def login
    
  end

  def index
    @rest = Home.get_json
  end

  def products

  end

  def payment
    
  end

  

end
