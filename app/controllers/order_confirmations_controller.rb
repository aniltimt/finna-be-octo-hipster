class OrderConfirmationsController < ApplicationController

  before_filter :login_required
  before_filter :spreadsheet_editor?
  before_filter :find_row

  def index
    @rows = @spreadsheet_row.spreadsheet_order_confirmation_rows
    if @rows.blank?
      (0..9).each do
        @rows << SpreadsheetOrderConfirmationRow.create(:spreadsheet_row_id => @spreadsheet_row.id)
      end
    end
  end

  def update
    @enabled_fields = current_user.spreadsheet_fields.map(&:codename)
    @row = @spreadsheet_row.spreadsheet_order_confirmation_rows.find_by_id(params[:id])
    unless @row.blank?
      if @row.respond_to?(params[:cell][:field].to_sym) &&
          @enabled_fields.include?("oc")

        if @row[params[:cell][:field].to_sym].is_a?(Date)
          old = @row[params[:cell][:field].to_sym].strftime("%m/%d/%Y")
        else
          old = @row[params[:cell][:field].to_sym]
        end

        @row.update_attributes(
          params[:cell][:field].to_sym => params[:cell][:data],
          (params[:cell][:field] + "_highlight").to_sym => (@sadmin ? false : true)
        )

        SpreadsheetLogItem.create(
          :user_id => current_user.id,
          :user_login => current_user.login,
          :ip => request.remote_ip,
          :message => "updated confirmation orders for row ##{@spreadsheet_row.id}
field \"#{params[:cell][:field]}\" #{HtmlDiff.diff(old.to_s, params[:cell][:data].to_s)} "
        )

        if params[:cell][:field] == "request_date" && !@spreadsheet_row.eta_port.blank?
          rows_count = @spreadsheet_row.spreadsheet_order_confirmation_rows.count(
            :conditions => "((NOT request_date is NULL) AND (request_date <= '#{@spreadsheet_row.eta_port - 7.days}'))"
          )
          if rows_count > 0 && !@spreadsheet_row.oc_highlight
            @spreadsheet_row.update_attribute(:oc_highlight, true)
          elsif rows_count == 0 && @spreadsheet_row.oc_highlight
            @spreadsheet_row.update_attribute(:oc_highlight, false)
          end
        end
        
      end
    else
      render :text => "fail"
      return false
    end
  end

  private

  def spreadsheet_editor?
    @role = current_user.role
    @sadmin = true if !@role.blank? && @role.codename == 'spreadsheet_admin'
    if @role.blank? || !['spreadsheet_editor', 'spreadsheet_admin'].include?(@role.codename)
      store_location
      flash[:notice] = "Please log in to see this page."
      redirect_to :controller => 'admin/account', :action => 'login'
      return false
    end
    current_user.update_attribute(:last_activity, Time.current)
  end

  def find_row
    @spreadsheet_row = SpreadsheetRow.find_by_id(params[:spreadsheet_id])
  end

end