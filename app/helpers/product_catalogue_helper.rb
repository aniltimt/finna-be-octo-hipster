module ProductCatalogueHelper
  
  def browse_categories
    if params[:id]
      @current_category = Category.find(params[:id])
      categories = Category.find(:all)
      @all_categories_ids = {}
      categories.each do |category| 
       @all_categories_ids[category.id] = []
       get_all_children(category.id, category)
      end
      @category_navigation = ""
      for category in Category.find(:all, :conditions => ["parent_id = 0"])
        if (!category.protected || category.passwords.map {|obj| obj.id}.include?(session[:password]))
          @category_navigation += "<ul style='padding:0px 0px 0px 18px;'>"
          get_navigation_for(category)
          @category_navigation += "</ul>"
        end
      end
    else
      @category_navigation = ""
      categories = Category.find_by_sql(["SELECT categories.*
          FROM categories
          INNER JOIN categories_passwords ON categories_passwords.password_id = #{session[:password] ? session[:password] : 0} AND categories.id = categories_passwords.category_id
          WHERE categories.enabled = 1 AND categories.parent_id = 0 AND categories.protected = 1

          UNION DISTINCT

          SELECT categories.*
          FROM categories
          WHERE categories.enabled = 1 AND categories.parent_id = 0 AND categories.protected = 0

          ORDER BY position"])
      @category_navigation += "<ul style='padding:0px 0px 0px 18px;'>"
      for category in categories
        @category_navigation += "<li>" + link_to(category.title, {:action => 'list', :id => category.id}, :class => "#{category.protected ? "category_protected" : "" }")+"</li>"
      end
      @category_navigation += "</ul>"
    end
    @category_navigation
  end

  
  def get_all_children(parent_category_id, category)
    if category.children.size > 0
      for child in category.children
        @all_categories_ids[parent_category_id] << child.id
        get_all_children(parent_category_id, child)
      end
    end
  end

  def get_navigation_for(category)
    if @current_category == category
      @category_navigation += "<li>" + link_to(category.title, {:action => 'list', :id => category.id}, :class => "current #{category.protected ? "category_protected" : ""}")
    else
      @category_navigation += "<li>" + link_to(category.title, {:action => 'list', :id => category.id}, :class => "#{category.protected ? "category_protected" : ""}")
    end
    if  @all_categories_ids[category.id].include?(params[:id].to_i) or params[:id].to_i == category.id
      for child in category.children
        if (!child.protected || child.passwords.map {|obj| obj.id}.include?(session[:password]))
          @category_navigation += "<ul style='padding:0px 0px 0px 18px;'>"
          get_navigation_for(child)
          @category_navigation += "</ul>"
        end
      end
    end
    @category_navigation += "</li>"
  end
  
end