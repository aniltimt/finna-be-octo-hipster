class ProductCatalogueController < ApplicationController

  before_filter :authenticate_customer
  
  layout 'default'

  def index
    list
    render :action => 'list'
  end
  
  def list
    if params[:id]
      @category = Category.find_by_id(params[:id])
      if @category && (!@category.protected || @category.passwords.map {|obj| obj.id}.include?(session[:password]))
        @styles = Style.find(:all, :conditions => ['category_id = ?', params[:id]], :order => 'position')
      else
        redirect_back_or_default('/product_catalogue')
      end
    else
      @categories = Category.find_by_sql(["SELECT categories.*
          FROM categories
          INNER JOIN categories_passwords ON categories_passwords.password_id = #{session[:password] ? session[:password] : 0} AND categories.id = categories_passwords.category_id
          WHERE categories.enabled = 1 AND categories.parent_id = 0 AND categories.protected = 1

          UNION DISTINCT

          SELECT categories.*
          FROM categories
          WHERE categories.enabled = 1 AND categories.parent_id = 0 AND categories.protected = 0

          ORDER BY position"])
    end
  end
  
  def browse
    category = Category.find(params[:id])
    if category.children.size > 0
      @categories = category.children
    end
    @styles = category.styles.find(:all, :order => 'position')
  end
  
  def show
    @category = Category.find_by_id(params[:id])
    if @category && (!@category.protected || @category.passwords.map {|obj| obj.id}.include?(session[:password]))
      @style = @category.styles.find(:first, :conditions => ["id = ? ", params[:style_id]])
      if @style
        @specifications = @style.specifications.visible.find(:all, :order => 'position')
        @gallery_items = @style.items.find(:all, :order => 'position')
      end
    else
      redirect_back_or_default('/product_catalogue')
    end
  end
  
  def find
    params[:search_string] ||= ""
    @styles = !params[:search_string].blank? ? Style.find(:all, :conditions => ["title LIKE ?", '%' + params[:search_string] + '%' ], :order => "title") : []
    @category = !params[:search_string].blank? ? Category.find(:all, :conditions => ["title LIKE ?", '%' + params[:search_string] + '%' ], :order => "title"): []
    render :action => 'find', :layout => 'default'
  end
  
  def search_by_size
    from = params[:size][:from]
    to = params[:size][:to]
    @specifications = Specification.find(:all, :conditions => ["od_ol_inch BETWEEN ? AND ? ", from, to])
    render :action => 'search_by_size', :layout => 'default'
  end 

  private

    def authenticate_customer
      authenticate_or_request_with_http_basic('Please enter your credentials. Contact Nicole@centrade.ca for an account if needed') do |user_name, password|
        Customer.find_and_authenticate_with(user_name, password)
      end
    end
  
end
