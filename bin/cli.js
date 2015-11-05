#!/usr/bin/env node

'use strict'

const fs = require('fs')
const path = require('path')

const gentry = require('gentry')
const min = require('minimist')

const wisdom = require('../lib/wisdom')
const argv = min(process.argv.slice(2))
const generatorName = argv._[0]

if (!argv._.length) usage()
doesGeneratorExist()

const generator = require('gentry-' + generatorName)
const questions = generator.scaffold.questions
const actions = generator.scaffold.actions

if (argv._.length !== 1) {
  // existing project, pass commands to generator
  argv._.shift()

  if (!generator.commands) process.exit(1)
  generator.commands(
    argv,
    JSON.parse(fs.readFileSync(path.join(process.cwd(), 'gentry.json'), 'utf8'))
  )
  process.exit(0)
}

wisdom(questions, (answers) => {
  // only run the actions
  if (argv.actions) return runActions()

  // full scaffold
  const dest = `${process.cwd()}/${answers.package.name}`
  console.log(`auto scaffold -\n${dest}`)
  gentry.autoScaffold({
    answers,
    templateDir: generator.scaffold.templateDir,
    dest
  }, (err) => {
    if (err) throw err
    const file = path.join(dest, 'gentry.json')
    fs.writeFileSync(file, JSON.stringify(answers, null, 2))
    runActions()
  })

  function runActions () {
    gentry.runActions({answers: answers, actions: actions}, (err) => {
      if (err) console.error(err)
      process.exit(err ? 1 : 0)
    })
  }
})

function usage () {
  console.log(`
    USAGE:
    # question user and just run actions
    $ gen <generator>
    # question user, run actions & auto-scaffold project with boba
    $ gen <generator> scaffold`)
  process.exit(0)
}

function doesGeneratorExist () {
  try {
    require.resolve(`gentry-${generatorName}`)
  } catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      console.log(`
      Generator ${generatorName} not installed, try:
      $ npm install -g gentry-${generatorName}`)
      process.exit(1)
    }
    throw err
  }
}
