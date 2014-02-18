class SpreadsheetsController < ApplicationController

  before_filter :login_required
  before_filter :spreadsheet_editor?

  layout "spreadsheet"

  def index

    order = 'po DESC'
    unless params[:sort].blank?
      order = params[:sort]
      order += " DESC" unless params[:desc].blank?
    end

    conditions = []
    unless params[:filter].blank?
      if !params[:filter][:etd_from].blank? && !params[:filter][:etd_to].blank?
        conditions << "etd BETWEEN '#{params[:filter][:etd_from].to_date}'
                           AND '#{params[:filter][:etd_to].to_date}'"
      elsif !params[:filter][:etd_from].blank?
        conditions << "etd >= '#{params[:filter][:etd_from].to_date}'"
      elsif !params[:filter][:etd_to].blank?
        conditions << "etd <= '#{params[:filter][:etd_to].to_date}'"
      end

      if !params[:filter][:eta_from].blank? && !params[:filter][:eta_to].blank?
        conditions << "eta_port BETWEEN '#{params[:filter][:eta_from].to_date}'
                                AND '#{params[:filter][:eta_to].to_date}'"
      elsif !params[:filter][:eta_from].blank?
        conditions << "eta_port >= '#{params[:filter][:eta_from].to_date}'"
      elsif !params[:filter][:eta_to].blank?
        conditions << "eta_port <= '#{params[:filter][:eta_to].to_date}'"
      end

      if !params[:filter][:delivery_date_from].blank? && !params[:filter][:delivery_date_to].blank?
        conditions << "delivery_date BETWEEN '#{params[:filter][:delivery_date_from].to_date}'
                                     AND '#{params[:filter][:delivery_date_to].to_date}'"
      elsif !params[:filter][:delivery_date_from].blank?
        conditions << "delivery_date >= '#{params[:filter][:delivery_date_from].to_date}'"
      elsif !params[:filter][:delivery_date_to].blank?
        conditions << "delivery_date <= '#{params[:filter][:delivery_date_to].to_date}'"
      end

      unless params[:filter][:business].blank?
        conditions << "(po LIKE '%#{params[:filter][:business]}%' OR po is NULL OR po = '')"
      else
        conditions << "(po LIKE '%cent%' OR po is NULL OR po = '')"
      end

      unless params[:filter][:color].blank?
        if params[:filter][:color] == "red"
          conditions << "(((NOT mbcc is NULL) AND (NOT etd is NULL) AND (DATE_ADD(mbcc, INTERVAL 1 WEEK) <= etd)) OR
              ((NOT request_eta is NULL) AND (NOT eta_port is NULL) AND (DATE_ADD(request_eta, INTERVAL 5 DAY) <= eta_port)) OR
              (oc_highlight = 1))"
        elsif params[:filter][:color] == "yellow"
          conditions << "(" + SpreadsheetField.all(:conditions => "codename <> 'oc'").map {|f| "#{f.codename}_highlight = 1"}.join(" OR ") + ")"
        end
      end

    else
      conditions << "(po LIKE '%cent%' OR po is NULL OR po = '')"
    end

    query = params[:"search-query"]
    unless query.blank?
      conditions << "(" + SpreadsheetField.all(:conditions => "codename <> 'oc'").map {|f| "#{f.codename} LIKE '%#{query}%'"}.join(" OR ") + ")"
    end

    @enabled_fields = current_user.spreadsheet_fields

    unless @sadmin
      conditions << "visible = 1"
    end

    @rows = SpreadsheetRow.paginate(
      :page => params[:page],
      :order => order,
      :conditions => conditions.join(" AND ")
    )
  end

  def enable
    if @sadmin
      row = SpreadsheetRow.find_by_id(params[:id])
      row.update_attribute(:visible, true) unless row.blank?
      SpreadsheetLogItem.create(
        :user_id => current_user.id,
        :user_login => current_user.login,
        :ip => request.remote_ip,
        :message => "visible row ##{row.id}"
      )
    end
    render :nothing => true
  end

  def disable
    if @sadmin
      row = SpreadsheetRow.find_by_id(params[:id])
      row.update_attribute(:visible, false) unless row.blank?
      SpreadsheetLogItem.create(
        :user_id => current_user.id,
        :user_login => current_user.login,
        :ip => request.remote_ip,
        :message => "unvisible row ##{row.id}"
      )
    end
    render :nothing => true
  end

  def create
    @enabled_fields = current_user.spreadsheet_fields
    if !params[:rows_count].blank? && !@enabled_fields.blank?

      SpreadsheetLogItem.create(
        :user_id => current_user.id,
        :user_login => current_user.login,
        :ip => request.remote_ip,
        :message => "added #{params[:rows_count].to_i} new row#{'s' if params[:rows_count].to_i > 1}"
      ) if params[:rows_count].to_i > 0

      params[:rows_count].to_i.times do
        SpreadsheetRow.create
      end
    end

    conditions = []

    order = 'id'
    unless params[:sort].blank?
      order = params[:sort]
      order += " DESC" unless params[:desc].blank?
    end

    unless @sadmin
      conditions << "visible = 1"
    end

    last_page = SpreadsheetRow.paginate(
      :page => 1,
      :order => order,
      :conditions => conditions.join(" AND ")
    ).total_pages

    @rows = SpreadsheetRow.paginate(
      :page => last_page,
      :order => order,
      :conditions => conditions.join(" AND ")
    )
  end

  def update
    @enabled_fields = current_user.spreadsheet_fields.map(&:codename)
    @row = SpreadsheetRow.find_by_id(params[:id])
    unless @row.blank?
      if @row.respond_to?(params[:cell][:field].to_sym) && @enabled_fields.include?(params[:cell][:field])

        if @row[params[:cell][:field].to_sym].is_a?(Date)
          old = @row[params[:cell][:field].to_sym].strftime("%m/%d/%Y")
        else
          old = @row[params[:cell][:field].to_sym]
        end

        @row.update_attributes(
          params[:cell][:field].to_sym => params[:cell][:data],
          (params[:cell][:field] + "_highlight").to_sym => (@sadmin ? false : true)
        )
        
        field = SpreadsheetField.find_by_codename(params[:cell][:field])

        SpreadsheetLogItem.create(
          :user_id => current_user.id,
          :user_login => current_user.login,
          :ip => request.remote_ip,
          :message => "updated row ##{@row.id} field \"#{field.name}\" #{HtmlDiff.diff(old.to_s, params[:cell][:data].to_s)} "
        )

        if params[:cell][:field] == "eta_port" && !@row.eta_port.blank?
          rows_count = @row.spreadsheet_order_confirmation_rows.count(
            :conditions => "((NOT request_date is NULL) AND (request_date <= '#{@row.eta_port - 7.days}'))"
          )
          if rows_count > 0 && !@row.oc_highlight
            @row.update_attribute(:oc_highlight, true)
          elsif rows_count == 0 && @row.oc_highlight
            @row.update_attribute(:oc_highlight, false)
          end
        end

      end
    end
  end

  def unhighlight
    if @sadmin
      row = SpreadsheetRow.find_by_id(params[:id])
      row.update_attribute(
        (params[:cell] + "_highlight").to_sym, false
      ) if !params[:cell].blank? && !row.blank? && row.respond_to?((params[:cell] + "_highlight"))
    end
    render :nothing => true
  end

  def log
    if @sadmin
      @log_items = SpreadsheetLogItem.paginate(
        :per_page => 10,
        :page => params[:log_page],
        :order => "id DESC"
      )
    end
  end

  def add_notes
    unless params[:notes_add].blank?
      @enabled_fields = current_user.spreadsheet_fields.map(&:codename)
      if @enabled_fields.include?("notes")
        @row = SpreadsheetRow.find_by_id(params[:id])
        @row.update_attributes(
          :notes => "#{@row.notes}#{current_user.login}: #{params[:notes_add]} (#{Time.current.strftime("%m/%d/%y@%I:%M%P")})\n",
          :notes_highlight => (@sadmin ? false : true)
        )

        SpreadsheetLogItem.create(
          :user_id => current_user.id,
          :user_login => current_user.login,
          :ip => request.remote_ip,
          :message => "updated row ##{@row.id} field \"Notes\". Add note: #{params[:notes_add]} "
        )
      end
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

end