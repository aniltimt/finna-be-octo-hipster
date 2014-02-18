class AdminNotifier < ActionMailer::Base
  
  def mail(letter)
    recipients "sean@centrade.ca"
    from "#{letter[:name]} <#{letter[:email]}>"
    subject "#{letter[:subject]}"
    body :letter => letter
    content_type "text/html"
  end

  def new_order_mail(order_details,user)
    recipients "sabedard@jig.to"
    from "website@ctiplastic.com <website@ctiplastic.com>"
    subject "New Order Added"
    body :order_details => order_details, :current_user => user
    content_type "text/html"
  end
  
  def quote_mail(letter, products, quantities)
    recipients "sean@centrade.ca"
    from "#{letter[:name]} <#{letter[:email]}>"
    subject "#{letter[:subject]}"
    body :letter => letter, :styles => products,:quantities => quantities
    content_type "text/html"
  end
  
  def sample_mail(letter, product)
    recipients "sean@centrade.ca"
    from "#{letter[:name]} <#{letter[:email]}>"
    subject "#{letter[:subject]}"
    body :letter => letter,:product=>product
    content_type "text/html"
  end

end
