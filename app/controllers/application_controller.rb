# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  MEDIA_FOLDER = "#{RAILS_ROOT}/assets/media_library_holder/"

  filter_parameter_logging :password

  include ExceptionNotifiable

  def initialize
    @config = AppConfig
  end

  include AccessControl
	
  helper_method :get_layout_for, :log_in_file
	
  def stringify_table( table, replace_char = '_', pluralize = true )
    string = table.to_s.gsub( /([A-Za-z])([A-Z])/, '\1' << replace_char.to_s << '\2' )
    string = string.pluralize if pluralize
    string = string.downcase
    string
  end
	 
  def tablify_string( string )
    eval( string.to_s.gsub( /_id/, '' ).singularize.split( '_' ).collect { |word| word.capitalize }.join )
  end
	
  def log_in_file(text, file)
    file_name = "#{RAILS_ROOT}/log/#{file}.log"
    if !File.exists?(file_name)
      file = File.open(file_name, 'w+')
    else
      file = File.open(file_name, 'a+')
    end			
    file.puts("#{Time.now} \n" + text + "\n")
    file.close		
  end
		
  def get_layout_for(page)
    page.template_item ? page.template_item.codename : "application"
  end

end