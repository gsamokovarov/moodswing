{expect, dontExpect, Expectation} = require '../lib/moodswing'

test = (desc, fn) ->
  unless fn?
    fn = desc
    desc = null

  try
    require('assert').doesNotThrow(fn)
  catch err
    # The ternary operator does not work here! 
    console.log "Failure in test #{if desc? then desc else "unknown block"}..."
    throw err

test "that equals works", ->
  expect(true).to be: true
  expect(true).to be: equal: true
  expect(true).to be: equal: of: true
  expect(undefined).to be: null
  dontExpect(true).to be: equal: to: false
  dontExpect(false).to be: true

test "that strict equals works", ->
  expect(true).to be: strictly: true
  dontExpect(undefined).to be: strictly: null

test "that deep equals works", ->
  expect({}).to be: deeply: {}

test "that property checking works", ->
  expect([]).to have: 'length'
  expect([]).to have: property: 'length'
  expect([]).to have: property: of: 'length'
  expect([]).to have: length: 0
  expect([]).to have: length: of: 0
  dontExpect({}).to have: 'length'
  dontExpect({}).to have: property: 'length'
  dontExpect({}).to have: property: of: 'length'

test "that expectations can be functions", ->
  expect(-> true).to be: true
  expect(-> false or true).to be: true

test "that expectations can handle errors", ->
  expect(-> throw new Error).to raise: Error
  expect(-> throw new Error).to throw: Error
  expect(-> throw new Error).to throws: Error
  dontExpect(-> null).to raise: Error
  dontExpect(-> null).to throw: Error
  dontExpect(-> null).to throws: Error

test "that expectations can check for instances", ->
  expect({}).to be: a: Object
  expect({}).to be: instance: of: Object
  expect({}).to be: an: instance: of: Object

test "that ::to won't call directives starting with 'to'", ->
  expect(-> expect(->).to to: 'choke').to raise: TypeError

test "that aliasing delegates correctly", ->
  expect(Expectation::).to have: 'have'
  expect(Expectation::).to have: 'haveProperty'
  expect(Expectation::).to have: 'havePropertyOf'

  expect(Expectation::).to have: 'be'
  expect(Expectation::).to have: 'beEqual'
  expect(Expectation::).to have: 'beEqualOf'
  expect(Expectation::).to have: 'beEqualTo'

  expect(Expectation::).to have: 'beStrictly'
  expect(Expectation::).to have: 'beStrictlyEqualTo'
  expect(Expectation::).to have: 'beStrictlyEqualOf'
  expect(Expectation::).to have: 'beStrictlyEqual'

  expect(Expectation::).to have: 'beDeeply'
  expect(Expectation::).to have: 'beDeeplyEqualTo'
  expect(Expectation::).to have: 'beDeeplyEqualOf'
  expect(Expectation::).to have: 'beDeeplyEqual'

  expect(Expectation::).to have: 'raise'
  expect(Expectation::).to have: 'throw'
  expect(Expectation::).to have: 'throws'
