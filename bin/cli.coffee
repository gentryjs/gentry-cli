fs = require 'fs'

gentry = require 'gentry'
min = require 'minimist'

wisdom = require '../lib/wisdom'

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
  require.resolve "gentry-#{generatorName}"

catch e
  if e.code is 'MODULE_NOT_FOUND' then return console.log """
    Generator #{generatorName} not installed, try:
    $ npm install -g gentry-#{generatorName}
    """

generator = require "gentry-#{generatorName}"

questions = generator.scaffold.questions

# only run the actions
if argv.actions
  return gentry.runActions questions, answers, ->
    process.exit()

# existing project, pass commands to generator
if argv._.length isnt 1
  argv._.shift()
  return generator.commands? argv,
    JSON.parse fs.readFileSync process.cwd() + 'gentry.json', 'utf8'

# full scaffold
wisdom questions, (answers) ->
  dest = "#{process.cwd()}/#{answers.package.name}"
  console.log """
  auto scaffold -
  #{dest}
  """

  gentry.autoScaffold
    answers: answers
    templateDir: generator.scaffold.templateDir
    dest: dest
  , (err) ->
    throw err if err?
    file = dest + '/gentry.json'
    fs.writeFileSync file, JSON.stringify answers, null, 2
