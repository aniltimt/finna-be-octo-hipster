// by Igonef
// updated by Andreyr
jQuery.fn.highlitable = function(params){
  var options = {
    start: 1
  };
  jQuery.extend(options, params);

  return this.each( function() {
    var rows = jQuery(this).find('tr');
        for (var i = options.start; i < rows.length; i++) {
          jQuery(rows[i]).hover(
            function(){
              $(this).addClass("highlight");
            },
            function(){
              $(this).removeClass("highlight");
            }
          );
        }
  });

};