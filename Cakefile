{exec} = require 'child_process'
puts = console.log

task 'compile', 'Compiles the project to JS.', (options) ->
  puts 'Compiling...'

  options.to ?= 'lib/'
  sh "coffee -b -o #{options.to} -c src/"

task 'test', 'Tests the library.', (options) ->
  invoke 'compile'
  puts "Testing..."

  sh "coffee test/moodswing.coffee"

sh = (cmd) ->
  attach = (fn) ->
    if sh.last
      sh.last.on 'exit', (code) -> fn() if code is 0
    else
      sh.last = fn()

  attach ->
    exec cmd, (status, output, error) ->
      puts [output, error].join '\n' if output or error

process.on 'SIGHUP', -> sh.last?.kill()

