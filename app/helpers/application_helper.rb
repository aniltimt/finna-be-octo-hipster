# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    def link_to_remove_fields(name, f)
      f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
    end
  
    def link_to_add_fields(name, f, association,style = nil)
      new_object = f.object.class.reflect_on_association(association).klass.new
      fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
	    render(association.to_s.singularize + "_fields", :f => builder)			
      end
      link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")",:style=> style)
    end

	def current_url?(options)
		url = case options
		when Hash
		  url_for options
		else
		  options.to_s
		end
		request.request_uri =~ Regexp.new('^' + Regexp.quote(clean(url)))
	end
	
	def clean(url)
		uri = URI.parse(url)
		uri.path.gsub(%r{/+}, '/').gsub(%r{/$}, '')
	end
	
	def nav_link_to(name, options)
		if current_url?(options)
			link_to name, options, :class => "curr"
		else
			link_to name, options
		end
	end  
	
	def link_to_view(item)
		link_to(image_tag("/images/cms/view.gif",:alt=>"view"),{:action=>"view", :id=>item}, :title=>"view")
	end 
	
	def link_to_edit(item)
		link_to(image_tag("/images/cms/edit.gif",:alt=>"edit"),{:action=>"edit", :id=>item}, :title=>"edit")
	end  
	
	def link_to_delete(item)
		link_to(image_tag("/images/cms/delete.gif",:alt=>"delete"),{:action=>"destroy", :id=>item}, :title=>"delete", :confirm=>"Are you sure you want do delete this item?", :method => :post)
	end
	
	def link_to_remove(options)
		link_to(image_tag("/images/cms/remove.gif",:alt=>"delete"),options, :title=>"remove", :confirm=>"Are you sure you want do remove this item?", :method => :post)
	end	
	
	def link_to_remove(item,opts)
		link_to(image_tag("/images/cms/remove.gif",:alt=>"remove"),opts, :title=>"remove", :confirm=>"Are you sure you want do remove this item?", :method => :post)
	end	
	
	def link_to_enable(item)
		if item.enabled
		link_to(image_tag("/images/cms/enabled.gif",:alt=>"disable"),{:action=>"disable", :id=>item}, :title=>"disable")
		else
		link_to(image_tag("/images/cms/disabled.gif",:alt=>"enable"),{:action=>"enable", :id=>item}, :title=>"enable")
		end
	end			

	def link_to_add_child(item)
		link_to(image_tag("/images/cms/add.gif",:alt=>"remove"),{:action=>"new", :id=>item}, :title=>"add")
	end	
	
	def link_to_elapse(item, items_name = "items")
    link = ""
		if (item.children.size > 0)
			link << link_to(
        image_tag("/images/cms/elapse.gif", :alt => "show", :id => "show_#{item.id}"),
        "javascript:void(0);",
        :title => "show",
        :onclick => "$('#show_#{item.id}').toggle(); $('#hide_#{item.id}').toggle(); $('##{items_name}_#{item.id}').toggle();"
      )
			link << link_to(
        image_tag("/images/cms/collapse.gif", :alt => "hide", :id => "hide_#{item.id}", :style => "display:none"),
        "javascript:void(0);",
        :title => "hide",
        :onclick => "$('#show_#{item.id}').toggle(); $('#hide_#{item.id}').toggle(); $('##{items_name}_#{item.id}').toggle();"
      )
		end
    return link
	end		

	def navigation(parent_id=0)
		if params[:url]
			current_navigation_item = NavigationItem.find(:first,:conditions=>["url=? and enabled=1","/#{params[:url]}"])
		elsif params[:id] and controller.controller_name=='media_library'
			object = MediaObject.find_by_id(params[:id])
			current_navigation_item=object.navigation_item if object
		end
		navigation_items = NavigationItem.find(:all,:conditions=>"parent_id=#{parent_id} and enabled=1",:order=>"position")
		navigation=""
		for navigation_item in navigation_items
			if current_url?(navigation_item.url) or (current_navigation_item and current_navigation_item.id==navigation_item.id)
				navigation+=link_to(navigation_item.name,navigation_item.url, :title=>navigation_item.name,:style=>'font-weight:bold')+"<br />"
				navigation+="<div style='padding-left:10px'>#{navigation(navigation_item.id)}</div>" if navigation_item.children.find(:all,:conditions=>"enabled=1").size>0
			else
				navigation+=link_to(navigation_item.name,navigation_item.url, :title=>navigation_item.name)+"<br />"
			end
		end
		navigation
	end
  
  def website_navigation(parent_id=0)
    if params[:url]
      current_navigation_item = NavigationItem.find(:first,:conditions=>["url=? and enabled=1","/#{params[:url]}"])
    elsif params[:id] and controller.controller_name=='media_library'
      object = MediaObject.find_by_id(params[:id])
      current_navigation_item=object.navigation_item if object
    end
    navigation_items = NavigationItem.find(:all,:conditions=>"parent_id=#{parent_id} and enabled=1",:order=>"position")
    navigation=""
    for navigation_item in navigation_items
      if navigation_item.graphical == true
        if current_url?(navigation_item.url) or (current_navigation_item and current_navigation_item.id==navigation_item.id)
          navigation += "<td>"+link_to("<img src='/admin/navigation/get_image/#{navigation_item.id}?type=current' style = 'border:0px;'>", navigation_item.url, :title=>navigation_item.name)+"</td>"
        else
          if navigation_item.hover_image != ''
            navigation += "<td>"+link_to("<img src='/admin/navigation/get_image/#{navigation_item.id}?type=default' style = 'border:0px;'   onmouseover = \"this.src='/admin/navigation/get_image/#{navigation_item.id}?type=hover'\", onmouseout = \"this.src='/admin/navigation/get_image/#{navigation_item.id}?type=default'\" >",navigation_item.url, :title=>navigation_item.name)+"</td>"
          else
            navigation += "<td>"+link_to("<img src='/admin/navigation/get_image/#{navigation_item.id}?type=default' style = 'border:0px;' />",navigation_item.url, :title=>navigation_item.name)+"</td>"
          end
        end
      else
        if current_url?(navigation_item.url) or (current_navigation_item and current_navigation_item.id==navigation_item.id)
          navigation += "<td height='38' width='64' nowrap='nowrap' align='center'>"+link_to(navigation_item.name.upcase,navigation_item.url, :title=>navigation_item.name, :class => 'cur_nav_link')+"</td>"
        else
          navigation += "<td height='38' width='64' nowrap='nowrap' align='center'>"+link_to(navigation_item.name.upcase,navigation_item.url, :title=>navigation_item.name, :class => 'nav_link')+"</td>"
        end
      end
    end
    navigation
  end
  
  def preload_graphic_navigation
    hovers = NavigationItem.find(:all,:conditions=>"graphical = 1 and enabled = 1 and hover_image != '' ", :order=>"position")
    for i in 0...(hovers.size)
      path = ("'/admin/navigation/get_image/" + hovers[i].id.to_s+"?type=hover'").to_s
      hovers[i] = path
    end
    path = ''
    for f in 0...(hovers.size)
      if !path.empty?
        path = path+','
      end 
      path = path + hovers[f]
    end
    return path
  end
		
	def get_icon(item)
		extension=item.media_file ? extension(item.media_file.file_name) : ""
		if File.exists?(RAILS_ROOT+"/public/images/media_library/mimetypes/#{extension}.png")
			image_tag("/images/media_library/mimetypes/#{extension}.png",{:alt=>"view",:width=>"22px",:height=>"22px"})	
		elsif File.exists?(RAILS_ROOT+"/public/images/media_library/mimetypes/#{item.media_type.codename}.png")
			image_tag("/images/media_library/mimetypes/#{item.media_type.codename}.png",{:alt=>"view",:width=>"22px",:height=>"22px"})	
		else
			image_tag("/images/media_library/mimetypes/unknown.png",{:alt=>"view",:width=>"22px",:height=>"22px"})	
		end										
	end
	
	def extension(path)
		ext = path.scan(/\..*$/).to_s
		ext.sub(/^\./, "")
	end
	
	def hidden_div_if(condition, attributes = {}, &block)
		if condition
			attributes[:style] = case attributes[:style]
			when nil 
				"display: none"
			else
				attributes[:style] + ";display: none"
			end 
		end
		attributes[:class] = "hidden_div" if !attributes[:class]	
		content_tag("div" , attributes, &block)
	end
	
	def header_for_hidden_div(title,close_element_id)
    return <<EOF
		<table width="100%" border="0" cellpadding="3" cellspacing="1">
			<tr class="div_header">
        <td >#{title}</td>
				<td width="10" class="div_header_close" align="center" onclick=\'$("##{close_element_id}").hide();\' title="close">X</td>
      </tr>
    </table>
EOF
	end 
	
	def year_string
		creation_year = 2007
		current_year = Date.today.year
		if current_year>creation_year 
		 return "#{creation_year} - #{current_year}"
		else
		 return "#{current_year}"
		end
	end  
	
	def page_title(text)
		render :partial => '/admin/partials/page_title', :locals => {:text => text}
	end 
  
  def front_page_title(text)
		render :partial => '/partials/page_title', :locals => {:text => text}
	end 
	
	def list_footer(items_name, collection)
		render :partial => '/admin/partials/list_footer', :locals => {:items_name => items_name, :collection => collection}
	end
	
	def adjust_quotes(text)
		text.gsub(/"/, "&quot;").gsub(/'/, "&#96;")
	end
	
	def strip_html(str, allow = [])
		str = str.strip || ''
		allow_arr = allow.join('|') << '|\/'
		str.gsub(/<(\/|\s)*[^(#{allow_arr})][^>]*>/,'')
	end
  
  def get_row_items_data(curr_index, collection, per_row)
    arr_items=Array.new(per_row)
    out_count = 0; max_count = collection.size
    for i in 0...per_row
      if curr_index+i<max_count
        arr_items[i]=collection[curr_index+i]
        out_count+=1
      else
        arr_items[i]=nil
      end
    end
    return arr_items, out_count
  end

  def order_footer(items_name, collection)
		render :partial => '/admin/partials/order_footer', :locals => {:items_name => items_name, :collection => collection}
  end

  def get_catalogue_login
    unless current_password
      return "<td height='38' width='64' nowrap='nowrap' align='center'>" + link_to("Login".upcase, "/passwords", :title => "Login", :class => "#{controller.controller_name == 'passwords' ? 'cur_' : ''}nav_link")+"</td>"
    else
      return "<td height='38' width='64' nowrap='nowrap' align='center'>" + link_to("Logout".upcase, "/passwords/logout", :title => "Logout", :class => 'nav_link')+"</td>"
    end
  end
  
end