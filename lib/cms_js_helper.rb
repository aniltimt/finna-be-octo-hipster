module CmsJsHelper

  def gmap_enabled?
    (get_config('show_google_map?') == '1') and (!get_config('google_map_longtitude').blank?) and (!get_config('google_map_latitude').blank?)
  end

  def set_google_map
    out=''
    if gmap_enabled?
      out=content_tag("script",nil,{:src =>"http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{get_config('google_map_key')}", :type => 'text/javascript'})+"\r"
      out+=javascript_tag(
        "var point = new GLatLng(#{get_config('google_map_longtitude')}, #{get_config('google_map_latitude')});

           function load() {
              if (GBrowserIsCompatible()) {
                var map = new GMap2(document.getElementById('map'));
                map.addControl(new GSmallMapControl());
                map.addControl(new GMapTypeControl());
                map.setCenter(new GLatLng(#{((get_config('google_map_longtitude').to_d) + 0.01).to_s},#{get_config('google_map_latitude')}), 13);

                var infoTabs = [
                  new GInfoWindowTab(\"Info\", \"<span style='font-size:12px;color:black;'>#{get_config('google_map_infobox')}</span>\"),
                  new GInfoWindowTab(\"Directions\", \"<br><b>Your Address:</b><form onsubmit=\"window.open('','directions','toolbar=1,location=1,directories=2,status=1,menubar=1,scrollbars=1,resizable=1,width=750,height=580')\" action=\"/contact_us/redirect\" method=\"post\" target=\"directions\"><input type=\"hidden\" name=\"to\" value=\"#{strip_html(get_config('contact_address')) unless get_config('contact_address').blank? }\"><input type=\"text\" name=\"addy\" id=\"addy\" style=\"width:200px\" /><br style=\"clear: both; visibility:visible; display: block; \" /><input type=\"submit\" value=\"Get Directions &raquo;\" class=\"order_button\" /></form>\")
                ];

            var marker = new GMarker(point);
            GEvent.addListener(marker, \"click\", function() {
              marker.openInfoWindowTabsHtml(infoTabs);
            });
            map.addOverlay(marker);
            marker.openInfoWindowTabsHtml(infoTabs);
          }
        }"
      )
    end
  end
  
  def focus(field_name)
    %{
    <script type="text/javascript">
    // <![CDATA[
      element = $('##{field_name}');
      if (element != null) {element.focus();element.select();}
    // ]]>
    </script>
    }
  end 
  
  def ruled_table(table_id,start=1)
    %{
    <script type="text/javascript">
    // <![CDATA[
      $('##{table_id}').highlitable({
      start: #{start}
    });
    // ]]>
    </script>
    }
  end
  
   def javascript_email_for(email, image_path = "")
    email_parts = email.split('@')
    str = javascript_tag"
            user = '#{email_parts[0]}';
            site = '#{email_parts[1]}';
            document.write('<a href=\"mailto:' + user + '@' + site + '\">#{image_tag(image_path,{:border => '0'}) unless image_path.blank? }' + user + '@' + site + '</a>');"
     str += "<NOSCRIPT>
        (Please enable JavaScript to see the e-mail address)
     </NOSCRIPT>"
  end

   def javascript_email_with_text(email, text)
    email_parts = email.split('@')
    str = javascript_tag"
            user = '#{email_parts[0]}';
            site = '#{email_parts[1]}';
            document.write('<a href=\"mailto:' + user + '@' + site + '\">#{text}</a>');"
     str += "<NOSCRIPT>
        (Please enable JavaScript to see the e-mail address)
     </NOSCRIPT>"
  end
   
end