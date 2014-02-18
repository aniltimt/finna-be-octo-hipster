require 'digest/sha1'
class User < ActiveRecord::Base

  STAFF_LOGIN = 'staff'

	belongs_to :role

  has_and_belongs_to_many :spreadsheet_fields, :join_table => "spreadsheet_fields_users"
	
	validates_presence_of :first_name, :last_name, :login, :email, :message => 'required'
	validates_uniqueness_of :login,  :message => 'already in use',
      :if => Proc.new { |user| (user.login != 'staff' || (User.staff_login.count > 2 && user.new_record?)) }
	validates_confirmation_of :password, :message => 'must match confirmation', :if => :confirm_password?  	
	validates_presence_of :password, :password_confirmation, :message => 'required', :if => :new_record? 
	validates_format_of :email, :message => 'invalid e-mail address', :allow_nil => true, :with => /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i 
	validates_length_of :first_name, :last_name, :maximum => 100, :allow_nil => true, :message => '{{count}}-character limit'
	validates_length_of :login, :within => 3..40, :allow_nil => true, :too_long => '{{count}}-character limit', :too_short => '{{count}}-character minimum'
	validates_length_of :password, :within => 5..40, :allow_nil => true, :too_long => '{{count}}-character limit', :too_short => '{{count}}-character minimum', :if => :validate_length_of_password?
	validates_length_of :email, :maximum => 255, :allow_nil => true, :message => '{{count}}-character limit'
	
	attr_writer :password_confirmation

  named_scope :staff_login, :conditions => {:login => STAFF_LOGIN}

  named_scope :authenticate, lambda { |login, password|
    {
      :conditions => {
        :login => login,
        :password => sha1(password),
        :enabled  => true
      }
    }
  }

  named_scope :spreadsheeter_authenticate, lambda { |login, password|
    {
      :conditions => {
        :login => login,
        :password => sha1(password),
        :enabled  => true,
        :remember_token => ''
      }
    }
  }

  named_scope :authenticate_staff, lambda { |password|
    {
      :conditions => {
        :login => STAFF_LOGIN,
        :password => sha1(password),
        :enabled  => true,
        :remember_token => ''
      }
    }
  }
  
#  named_scope :spreadsheet_editors,
#    :conditions => {:role_id => Role.find_by_codename('spreadsheet_editor').id}

  named_scope :spreadsheeters, :conditions => [
    "role_id IN (?)",
    Role.all(:conditions => "codename LIKE '%spreadsheet%'").map(&:id)
  ]

  def self.autologout
    users = User.spreadsheeters.all :conditions => ["last_activity <= ? AND remember_token <> ''", Time.current - 5.minutes]
    for user in users
      user.update_attribute(:remember_token, "")
      SpreadsheetLogItem.create(
        :user_id => user.id,
        :user_login => user.login,
        :ip => "",
        :message => "auto logged out"
      )
    end unless users.blank?
  end
	
	private
	
	def self.sha1(phrase)
		Digest::SHA1.hexdigest("--kd-cms--#{phrase}--")
	end

	def validate_length_of_password?
    new_record? || !password.blank?
	end

  def confirm_password?
    new_record? || !password.blank?
  end

  before_create :encrypt_password

  def encrypt_password
    self.password = self.class.sha1(password)
  end

  before_update :encrypt_password_unless_empty_or_unchanged

  def encrypt_password_unless_empty_or_unchanged
    user = self.class.find(self.id)
    case password
    when ''
      self.password = user.password
    when user.password
    else
      encrypt_password
    end
  end

end
