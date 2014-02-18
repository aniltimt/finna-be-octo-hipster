class SpreadsheetRow < ActiveRecord::Base

  def self.per_page
    50
  end

  has_many :spreadsheet_order_confirmation_rows

end