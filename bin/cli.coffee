min = require 'minimist'
gentry = require 'gentry'
runner = require 'gentry-runner-cli'

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
  questions = generator.questions

  runner questions, (answers) ->
    # just actions
    if argv.actions
      return gentry.runActions questions, answers, ->
        process.exit()

    # full scaffold
    dest = process.cwd() + "/#{answers.package.name}"

    console.log "auto scaffold -"
    console.log dest
    gentry.autoScaffold
      answers: answers
      templateDir: generator.templateDir
      dest: dest
    , ->
      process.exit()

catch e
  if e.code = 'MODULE_NOT_FOUND'
    return console.log """
    Generator #{generatorName} not installed, try:
    $ npm install -g gentry-#{generatorName}
    """
  return console.log e
