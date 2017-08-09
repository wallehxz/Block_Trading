module ApplicationHelper
  def model_errors(model,attribute)
    return model.errors.messages[attribute.to_sym][0] if model.errors.messages[attribute.to_sym]
  end

end
