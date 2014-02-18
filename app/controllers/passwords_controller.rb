class PasswordsController < ApplicationController

  layout 'product_catalogue'

  def index

  end

  def login
    return unless request.post?
    self.current_password = Password.find_by_value(params[:password][:value])
		if current_password
			flash[:notice] = "Logged in successfully"
			redirect_back_or_default('/product_catalogue')
		else
      flash[:notice] = "Incorrect password"
      redirect_to :action => nil
		end
  end

  def logout
    self.current_password = nil
    redirect_back_or_default('/product_catalogue')
  end
  
end