// by Igonef
jQuery.extend({
  upcase: function(str) {return str.toUpperCase()},
  downcase: function(str) {return str.toLowerCase()},
  strip: function(str) { return str.replace(/^\s+/, '').replace(/\s+$/, '') },
  toInteger: function(str) { return parseInt(str) },
  toSlug: function(str) { 
    return jQuery.downcase(jQuery.strip(str)).replace(/[^-a-z0-9~\s\.:;+=_]/g, '').replace(/[\s\.:;=+]+/g, '_')
  }
});