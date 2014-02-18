module ContactHelper
  
  def my_options_from_collection_for_select(collection, value_method, text_method, selected = nil)
    options = collection.map do |element|
      [element.send(text_method), element.send(value_method)]
    end
    my_options_for_select(options, selected)
  end
  
  def my_options_for_select(container, selected = nil)
    container = container.to_a if Hash === container
    options_for_select = container.inject([]) do |options, element|
      text, value = option_text_and_value(element)
      selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
      options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}>#{html_escape(text.to_s)}</option>)
    end
 
    options_for_select.join(" ")
  end
  
  private

  def option_text_and_value(option)
    # Options are [text, value] pairs or strings used for both.
    if !option.is_a?(String) and option.respond_to?(:first) and option.respond_to?(:last)
      [option.first, option.last]
    else
      [option, option]
    end
  end

  def option_value_selected?(value, selected)
    if selected.respond_to?(:include?) && !selected.is_a?(String)
      selected.include? value
    else
      value == selected
    end
  end

end
