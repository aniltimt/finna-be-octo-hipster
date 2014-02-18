# Multilocale support
module OverrideTestProcess

  # Executes a request simulating GET HTTP method and set locale param
  def get(action, parameters = {}, session = nil, flash = nil)
    parameters[:locale] = I18n.locale
    super(action, parameters, session, flash)
  end

  # Executes a request simulating POST HTTP method and set locale param
  def post(action, parameters = {}, session = nil, flash = nil)
    parameters[:locale] = I18n.locale
    super(action, parameters, session, flash)
  end

  # Executes a request simulating PUT HTTP method and set locale param
  def put(action, parameters = {}, session = nil, flash = nil)
    parameters[:locale] = I18n.locale
    super(action, parameters, session, flash)
  end

  # Executes a request simulating DELETE HTTP method and set locale param
  def delete(action, parameters = {}, session = nil, flash = nil)
    parameters[:locale] = I18n.locale
    super(action, parameters, session, flash)
  end

  # Executes a request simulating HEAD HTTP method and set locale param
  def head(action, parameters = {}, session = nil, flash = nil)
    parameters[:locale] = I18n.locale
    super(action, parameters, session, flash)
  end

end