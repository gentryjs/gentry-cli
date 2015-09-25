min = require 'minimist'
gentry = require 'gentry'
runner = require 'gentry-runner-cli'
jsonfile = require 'jsonfile'
async = require 'async'

usage = ->
  console.log """
  USAGE:
  # question user and just run actions
  $ gen <generator>
  # question user, run actions & auto-scaffold project with boba
  $ gen <generator> scaffold
  """

argv = min process.argv.slice(2)
generatorName = argv._[0]

# no args = print usage
if argv._.length is 0 then return usage()

try
  generator = require "gentry-#{generatorName}"
  questions = generator.scaffold.questions

  # only run the actions
  if argv.actions
    return gentry.runActions questions, answers, ->
      process.exit()

  # existing project, pass commands to generator
  if argv._.length isnt 1
    argv._.shift()
    src = "#{process.cwd()}/gentry.json"
    return jsonfile.readFile src, (err, config) ->
      return console.error err if err?
      generator.commands? argv, config

  # full scaffold
  runner questions, (answers) ->
    dest = "#{process.cwd()}/#{answers.package.name}"
    console.log """
    auto scaffold -
    #{dest}
    """

    scaffold = (cb) ->
      gentry.autoScaffold
        answers: answers
        templateDir: generator.scaffold.templateDir
        dest: dest
      , cb

    saveAnswers = (cb) ->
      file = "#{dest}/gentry.json"
      jsonfile.spaces = 2
      jsonfile.writeFile file, answers, cb

    async.series [
      scaffold,
      saveAnswers
    ], (err) ->
      console.error err if err?

catch e
  if e.message is "Cannot find module 'gentry-#{generatorName}'"
    return console.log """
    Generator #{generatorName} not installed, try:
    $ npm install -g gentry-#{generatorName}
    """
  return console.log e
