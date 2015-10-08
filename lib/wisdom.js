const _ = require('lodash')
const inquirer = require('inquirer')
const packageQuestions = require('./packageQuestions')

module.exports = function (questions, done) {
  inquirer.prompt(_.map(packageQuestions, transform), (pkg) =>
    inquirer.prompt(_.map(questions, transform), (answers) =>
      done({'package': pkg, answers})
    )
  )
}

function transform (details, question) {
  return {
    name: question,
    message: details.prompt,
    type: getType(details.input.type, _.has(details, 'input.enum')),
    choices: details.input.enum
  }
}

function getType (type, hasEnum) {
  if (type === Boolean) return 'confirm'
  if (type === Array || Array.isArray(type)) return 'checkbox'
  return hasEnum ? 'list' : 'input'
}
