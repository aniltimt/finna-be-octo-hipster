class ContactController < ApplicationController
  
  layout 'default'

  def index
  end

  def send_mail
    AdminNotifier.deliver_mail(params[:letter])
    redirect_to :action => 'index'
    flash[:notice] = 'The letter has been successfully sent!'
  end
  
  def quote_mail  
    AdminNotifier.deliver_quote_mail(params[:letter], params[:products], params[:quantities])
    redirect_to :action => 'index'
    flash[:notice] = 'The letter has been successfully sent!'
  end
  
  def sample_mail
    product = Style.find(params[:letter][:product])
    AdminNotifier.deliver_sample_mail(params[:letter], product)
    redirect_to :action => 'index'
    flash[:notice] = 'The letter has been successfully sent!'
  end
  
end