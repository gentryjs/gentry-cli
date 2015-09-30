 module.exports = (question, details) ->
  tmp = details.input.type
  type = if tmp[0]? then 'object' else typeof tmp()

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