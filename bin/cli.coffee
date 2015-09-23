path      = require 'path'
min       = require 'minimist'
gentry    = require 'gentry'
runner    = require 'gentry-runner-cli'

#questions = require '../app/questions'
#actions   = require '../app/actions'
#templateDir = path.resolve './app/templates/'

# usage message
usage = ->
  console.log "USAGE:"
  console.log "# question user and just run actions"
  console.log "$ gen <generator>"
  console.log "# question user, run actions & auto-scaffold project w/ boba"
  console.log "$ gen <generator> scaffold"

argv = min process.argv.slice(2)

# no args = print usage
if argv._.length is 0 then return usage()

else

  try

    generator = require "gentry-#{argv._[0]}"
    questions = generator.questions

    runner questions, (answers) ->

      # scaffold
      if !argv._[1]?

        dest = process.cwd() + "/#{answers.package.name}"

        console.log "auto scaffold -"
        console.log dest
        gentry.autoScaffold
          answers: answers
          templateDir: generator.templateDir
          dest: dest
        , ->
          process.exit()


      # just actions
      else if argv._[1] is '-actions'

        gentry.runActions questions, answers, ->
          process.exit()

      # no args = usage
      else
        usage()

  catch e
    console.log e
    console.log "Generator '#{argv._[0]}' not installed, try:"
    console.log "$ npm install -g gentry-#{argv._[0]}"
    process.exit()
