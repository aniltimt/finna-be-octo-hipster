module AccessControl

    unloadable #TODO: investigate this line (it helps me from  "A copy of AccessControl has been removed from the module tree but is still active!" error when use upload_progress plugin)
    def logged_in?
      current_user ? true : false
    end

    # Accesses the current user from the session.
    def current_user
      @_current_user ||= user_from_cookie
    end

    # Store the given user in the session.
    def current_user=(user)
      unless user.blank?
        cookies[:remember_token] = {
          :value   => user.remember_token,
          :expires => 1.year.from_now.utc
        }
      end
      @_current_user = user
    end

    def user_from_cookie
      if token = cookies[:remember_token]
        User.find_by_remember_token(token)
      end
    end

    #Access the current password from the session
    def current_password
      password = Password.find_by_id(session[:password]) if session[:password]
      @current_password = password.blank? ? nil : password
    end
    
    # Store the given password in the session.
    def current_password=(password)
      session[:password] = (password.nil? || password.is_a?(Symbol)) ? nil : password.id
      @current_password = password
    end

	# Stores location and redirects to the login area
    def login_required
      if logged_in?
        return true
      else
        flash[:notice] = "Please log in to see this page."
        if request.xhr?
          session[:return_to] = "/spreadsheets" if request.request_uri =~ Regexp.new('^/spreadsheets')
          render :update do |page|
            page.call "gotourl", "admin/account/login"
          end
        else
          store_location
          redirect_to :controller => 'admin/account', :action => 'login'
        end
        return false
      end
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :current_password
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end

	protected

	def access_control(perms = {})
		if @_current_user.role && @_current_user.role.permissions
			permissions = permission_strings
			perm = nil
			current_action = params[:action]
			perms.each {|key, ps|
				if ps.include?(current_action)
					perm = self.controller_name + "/" + key.to_s
					return true	if permissions.include?(perm)
				end
			}
      if request.request_uri =~ Regexp.new('^/admin')
        layout = "application"
      else
        layout = "default"
      end
			render :file => "/admin/account/access_denied", :layout => layout
      return false
		else
			render :file => "/admin/account/access_denied", :layout => layout
      return false
		end
	end

	def permission_strings
    a = []
    @_current_user.role.permissions.each{|p| a << p.name }
    a
	end

end