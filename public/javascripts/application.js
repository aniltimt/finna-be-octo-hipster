function blockContextClick(){
  $(document).bind("contextmenu", function(e){
    return false;
  });
}
function gotourl(url) {
  window.location.pathname = url;
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).parent().parent(".fields").hide();
  $(link).parent().parent(".fields").next().hide();
}


function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  content = content.replace(regexp, new_id);
  content = content.replace("barcode_change", 'barcode_change'+ new_id);  
	content = content.replace("row_change_show", 'barcode_change'+ new_id);  
  $(link).parent().parent().before(content);
}