 module.exports = (question, details) ->
  type = typeof details.input.type()

  options = details.input.enum

  transformed =
    name: question
    message: details.prompt

  transformed.type =
    switch type
      when "boolean" then 'confirm'
      when "object" then 'checkbox' #array
      when "string"
        if options? then 'list' else 'input'

  transformed.choices = options if options?

  return transformed