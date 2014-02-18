module SpreadsheetsHelper

  def rewrite_params(params)
    return "" if params.blank?
    text = []
    for key in params.keys
      text << "filter[#{key}]=#{params[key]}"
    end
    return text.join("&")
  end

end