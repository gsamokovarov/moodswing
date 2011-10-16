{expect, dontExpect, Expectation} = require '../lib/period'

test = (fn) ->
  require('assert').doesNotThrow(fn)

test ->
  expect(true).to be: true
  expect(true).to be: equal: true
  expect(true).to be: equal: of: true
  dontExpect(true).to be: equal: to: false
  dontExpect(false).to be: true

test ->
  expect({length: 1}).to have: 'length'
  expect([]).to have: property: 'length'
  expect([]).to have: property: of: 'length'
  expect([]).to have: length: 2

test ->
  expect(-> throw Error).to raise: Error
  expect(-> throw Error).to throw: Error
  expect(-> throw Error).to throws: Error
  dontExpect(-> null).to raise: Error
  dontExpect(-> null).to throw: Error
  dontExpect(-> null).to throws: Error
