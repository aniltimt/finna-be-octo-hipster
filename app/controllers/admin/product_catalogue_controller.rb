class Admin::ProductCatalogueController < ApplicationController
  before_filter :login_required, :except => ["get_gallery_image","get_style_image","get_image"]
  before_filter :check_permissions, :except => ["get_gallery_image","get_style_image","get_image"]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }	
    
  protected
  
  def check_permissions
    access_control({
        :create =>  ["new",
          "new_specification",
          "create",
          "create_item",
          "create_style",
          "create_specification"],
        :edit   =>  ["edit",
          "edit_style",
          "edit_item",
          "edit_specification",
          "update_positions",
          "update_style_positions",
          "update_item_positions",
          "update_specification_positions",
          "update_style",
          "update_item",
          "update_image_size",
          "update_style_image_size",
          "update_category_image_size",
          "update_gallery_image_size",
          "update_positions",
          "update_specification",
          "enable",
          "disable",
          "update"],
        :delete =>  ["destroy",
          "delete_image",
          "delete_gallery_image",
          "destroy_item",
          "delete_style_image",
          "destroy_style",
          "destroy_specification",],
        :list   =>  ["index",
          "list",
          "browse_categories"],
        :view   =>  ["show",
          "get_image",
          "get_style_image",
          "get_gallery_image",]		
      })
  end  
 
  public
     
  def index
    @categories = Category.all(:conditions => "parent_id = 0", :order => "position")
    render :action => 'list'
  end

  alias_method :list, :index

  def new
    @category = Category.new(:parent_id => params[:id] || 0)
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @category = Category.find(params[:id])
    @styles = @category.styles
  end

  def update
    @category = Category.find_by_id(params[:id])
    if @category.update_attributes(params[:category])
      flash[:notice] = 'Category was successfully updated.'
      redirect_to :action => 'edit', :id => @category
    else
      render :action => 'edit'
    end
  end

  def destroy             
    category = Category.find_by_id(params[:id])
    category.destroy if category
    redirect_to :action => 'list'
  end

  def enable
    category = Category.find_by_id(params[:id])
    category.update_attribute(:enabled, true)
    redirect_to :action => 'list'
  end

  def disable
    category = Category.find_by_id(params[:id])
    category.update_attribute(:enabled, false)
    redirect_to :action => 'list'
  end

  def update_positions
    if params["categories_" + params[:parent_id]]
      params["categories_" + params[:parent_id]].each_with_index do |id, position|
        Category.update(id, :position => position)
      end		
    end

    @categories = Category.all(:conditions => "parent_id = #{params[:parent_id]}", :order => "position")

    if params[:parent_id] == '0' && request.xml_http_request?
      render :update do |page|
        page.replace_html(
          "categories_holder_#{params[:parent_id]}",
          :partial => "categories_holder",
          :locals => {:parent_id => params[:parent_id], :categories => @categories}
        )
      end
    else
      render :nothing => true
    end		
  end

  def delete_image
    category = Category.find_by_id(params[:id])
    category.update_attribute(:image, nil)
    render :nothing => true
  end

  def browse_categories
    @category = Category.find_by_id(params[:id]) unless params[:id] == "0"
    @categories = Category.all(:conditions => ["parent_id = 0 AND id <> ?", @category ? @category.id : 0], :order => "position")
    if request.xml_http_request?
      render :update do |page|
        page.replace_html "categories", :partial => "browse_categories"
      end
    end	
  end	     
  
  def create_style
    if request.post?
      @style = Style.new(params[:style])
      if @style.save
        flash[:notice] = 'Style was successfully created.'
        redirect_to :action => 'edit', :id => @style.category_id
      else 
        @specifications = @style.specifications.all :order => 'position'
        @gallery_items = @style.items.all :order => 'position'
        render :action => 'edit_style'
      end
    end
  end
  
  def update_style
    @style = Style.find_by_id(params[:id])
    if @style.update_attributes(params[:style])
      flash[:notice] = 'Style was successfully updated.'
      redirect_to :action => 'edit_style', :id => @style
    else
      @specifications = @style.specifications.all :order => 'position'
      @gallery_items = @style.items.all :order => 'position'
      render :action => :edit_style
    end
  end
  
  def edit_style
    @style = Style.find(params[:id])
    @specifications = @style.specifications.all :order => 'position'
    @gallery_items = @style.items.all :order => 'position'
  end
  
  def destroy_style
    style = Style.find_by_id(params[:id])
    if style
      @category = style.category
      style.destroy
      @styles = @category.styles.all :order => 'position'
    end
    if request.xhr?
      render :update do |page|
        page.replace_html "styles", :partial => "styles" 
      end
    end
  end

  def delete_style_image
    style = Style.find_by_id(params[:id])
    if %w[image image2 image3 palette].include? params[:type]
      style.update_attribute(params[:type], nil)
      head :ok
    else
      head :not_implemented
    end
  end

  def update_style_positions
    params[:styles].each_with_index do |id, position|
      Style.update(id, :position => position)
    end
    category = Category.find_by_id(params[:category_id])
    @styles = Style.all(:conditions => ['category_id = ?', category.id], :order => 'position')
    if request.xml_http_request?
      render :update do |page|
        page.replace_html "styles", :partial => "styles"
      end
    else
      render :nothing => true
    end
  end

  def create_item
    if request.post?
      @gallery_item = GalleryItem.new(params[:gallery_item])
      if @gallery_item.save
        flash[:notice] = 'Gallery item was successfully created.'
        redirect_to :action => 'edit_style', :id => @gallery_item.style_id
      else
        render :action => 'create_item'
      end 
    end
  end

  def edit_item
    @gallery_item = GalleryItem.find_by_id(params[:id])
  end

  def update_item
    @gallery_item = GalleryItem.find_by_id(params[:id])
    if request.post?
      if @gallery_item.update_attributes(params[:gallery_item])
        flash[:notice] = 'Gallery item was successfully updated.'
        redirect_to :action => 'edit_style', :id => @gallery_item.style
      else
        render :action => 'update_item', :id => @gallery_item
      end
    end
  end

  def destroy_item
    @style = Style.find(params[:style_id])
    @gallery_item = GalleryItem.find_by_id(params[:id])
    if @gallery_item
      @gallery_item.destroy
      @specifications = @style.specifications.all :order => 'position'
      @gallery_items = @style.items.all :order => 'position'
      if request.xhr?
        render :update do |page|
          page.replace_html "gallery_items", :partial => "gallery_items" 
        end
      end
    end
  end

  def delete_gallery_image
    gallery_item = GalleryItem.find_by_id(params[:id])
    gallery_item.update_attribute(:image, nil)
    render :nothing => true
  end

  def update_item_positions
    params[:gallery_items].each_with_index do |id, position|
      GalleryItem.update(id, :position => position)
    end
    style = Style.find_by_id(params[:style_id])
    @specifications = style.specifications.all :order => 'position'
    @gallery_items = GalleryItem.all(:conditions => ['style_id = ?', style.id], :order => 'position')
    if request.xml_http_request?
      render :update do |page|
        page.replace_html "gallery_items", :partial => "gallery_items"
      end
    else
      render :nothing => true
    end
  end 
   
  def new_specification
    @style = Style.find(params[:id])
    @specification = Specification.new
  end

  def create_specification
    @style = Style.find(params[:id])
    @specification = Specification.new(params[:specification])
    @specification.style = @style;

    if @specification.save
      flash[:notice] = 'Specification was successfully created.'
      redirect_to :action => 'edit_style', :id => @style.id
    else
      render :action => 'create_specification'
    end 
  end

  def update_specification
    @specification = Specification.find_by_id(params[:id])
    puts YAML::dump(params)
    if @specification.update_attributes(params[:specification])
      flash[:notice] = 'Specification was successfully updated.'
      redirect_to :action => 'edit_style', :id => @specification.style_id
    else
      render :action => 'edit_specification', :id => @specification.id
    end
  end

  def edit_specification
    @specification = Specification.find_by_id(params[:id])
  end

  def destroy_specification
    @style = Style.find(params[:style_id])
    @specification = Specification.find_by_id(params[:id])
    if @specification
      @specification.destroy
      @specifications = @style.specifications.all :order => 'position'
      if request.xml_http_request?
        render :update do |page|
          page.replace_html "specifications", :partial => "specifications" 
        end
      end
    end
  end

  def update_specification_positions
    params[:specifications].each_with_index do |id, position|
      Specification.update(id, :position => position)
    end
    style = Style.find_by_id(params[:style_id])
    @specifications = style.specifications.all :order => 'position'
    if request.xml_http_request?
      render :update do |page|
        page.replace_html "specifications", :partial=>"specifications"
      end
    else
      render :nothing => true
    end
  end 
 
end
