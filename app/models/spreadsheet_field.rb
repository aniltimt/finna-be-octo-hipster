class SpreadsheetField < ActiveRecord::Base

  has_and_belongs_to_many :users, :join_table => "spreadsheet_fields_users"

end