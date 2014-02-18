class Admin::AccountController < ApplicationController

	after_filter :reset_flash, :only => :login

	def reset_flash
		flash[:notice] = nil  
	end

	def login
    redirect_to "/admin" if logged_in?
		return unless request.post?
    if ["staff", "sam", "bellan", "apex"].include?(params[:login].downcase)
      if User.authenticate(params[:login], params[:password]).first.blank?
        notice = "That account does not exist or it is disabled. Please contact the administrator"
      else
        user = User.spreadsheeter_authenticate(params[:login], params[:password]).first
        if user.blank?
          notice = "This account is currently used. Please wait until the user log out"
        end
      end
    else
      user = User.authenticate(params[:login], params[:password]).first
      notice = "That account does not exist or it is disabled. Please contact the administrator"
    end
    
		unless user.blank?
      user.update_attributes(
        :remember_token => Digest::SHA1.hexdigest("#{rand.to_s}--#{Time.current}--}"),
        :last_activity => Time.current
      )
      role = user.role
      if ['spreadsheet_editor', 'spreadsheet_admin'].include?(role.codename)
        SpreadsheetLogItem.create(
          :user_id => user.id,
          :user_login => user.login,
          :ip => request.remote_ip,
          :message => "logged in"
        )
      end unless role.blank?
      self.current_user = user
			flash[:notice] = "Logged in successfully"
			redirect_back_or_default('/admin')
		else
      flash[:notice] = notice
		end
	end

	def profile
		@user = current_user
	end

	def logout
    unless current_user.blank?
      current_user.update_attribute(:remember_token, "")
      SpreadsheetLogItem.create(
        :user_id => current_user.id,
        :user_login => current_user.login,
        :ip => request.remote_ip,
        :message => "logged out"
      )
    end
    cookies.delete(:remember_token)
    self.current_user = nil
		flash[:notice] = "You have been logged out."
		redirect_to :controller => 'account', :action=>"login"
	end

end
