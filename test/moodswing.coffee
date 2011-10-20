{expect, dontExpect, Expectation} = require '../lib/moodswing'
puts = console.log

test = (fn) ->
  require('assert').doesNotThrow(fn)

test ->
  expect(true).to be: true
  expect(true).to be: equal: true
  expect(true).to be: equal: of: true
  dontExpect(true).to be: equal: to: false
  dontExpect(false).to be: true

test ->
  expect([]).to have: 'length'
  expect([]).to have: property: 'length'
  expect([]).to have: property: of: 'length'
  expect([]).to have: length: 0
  expect([]).to have: length: of: 0
  dontExpect({}).to have: 'length'
  dontExpect({}).to have: property: 'length'
  dontExpect({}).to have: property: of: 'length'

test ->
  expect(-> throw new Error).to raise: Error
  expect(-> throw new Error).to throw: Error
  expect(-> throw new Error).to throws: Error
  dontExpect(-> null).to raise: Error
  dontExpect(-> null).to throw: Error
  dontExpect(-> null).to throws: Error

test ->
  expect({}).to be: a: Object
  expect({}).to be: instance: of: Object
  expect({}).to be: an: instance: of: Object

test ->
  expect(Expectation::).to have: 'have'
  expect(Expectation::).to have: 'haveProperty'
  expect(Expectation::).to have: 'havePropertyOf'

  expect(Expectation::).to have: 'be'
  expect(Expectation::).to have: 'beEqual'
  expect(Expectation::).to have: 'beEqualOf'
  expect(Expectation::).to have: 'beEqualTo'

  expect(Expectation::).to have: 'raise'
  expect(Expectation::).to have: 'throw'
  expect(Expectation::).to have: 'throws'
