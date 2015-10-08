_ = require 'lodash'
inquirer = require 'inquirer'
packageQuestions = require './packageQuestions'

getType = (type, hasEnum) ->
  return 'confirm' if type is Boolean
  return 'checkbox' if type is Array or Array.isArray type
  if hasEnum then 'list' else 'input'

transform = (details, question) ->
  name: question
  message: details.prompt
  type: getType details.input.type, details.input.enum?
  choices: details.input.enum

module.exports = (questions, done) ->
  inquirer.prompt _.map(packageQuestions, transform), (pkg) ->
    inquirer.prompt _.map(questions, transform), (answers) ->
      done {package: pkg, answers}
