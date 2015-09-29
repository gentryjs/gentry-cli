inquirer = require 'inquirer'
packageQuestions = require './packageQuestions'
transform = require './transform'

module.exports = (questions, done) ->
  pkgQuestion = []
  generatorQuestion = []

  iterate = (questions, arr) ->
    for question, details of questions
      transformed = transform(question, details)
      arr.push transformed

  iterate questions, generatorQuestion
  iterate packageQuestions, pkgQuestion

  inquirer.prompt pkgQuestion, (pkg) ->
    inquirer.prompt generatorQuestion, (answers) ->
      done answers =
        package: pkg
        answers: answers
