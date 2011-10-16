{inspect} = require 'util'
assert = require 'assert'
AssertionError = assert.AssertionError

###
Primitive safe ``Object.keys`` implementation.
###
keys = (something) ->
  Object.keys(Object something)

###
Takes the first object from an object or array.
###
first = (it) ->
  return it[0] if Array.isArray(it) or typeof it is 'string'
  it[keys(it)[0]]

###
Capitalizes the string `str`.
###
capitalize = (str) ->
  "#{str[0].toUpperCase()}#{str[1...]}"

###
The expectation object is responsible for the assertions behavior.
###
class Expectation
  constructor: (@target, options = {}) ->
    @negate = options.negate or false

  ###
  Assert @target to be equal to `other` object.
  ###
  beEqual: (other) ->
    assert.equal @target, other unless @negate
    assert.notEqual @target, other if @negate
    this
  
  ###
  Assert @target to be an instance of `kind`.
  ###
  beAnInstanceOf: (kind) ->
    unless @target instanceof kind
      assert.fail("Expected #{@target} to be an instance of #{kind}")
    this

  ###
  Assert @target have a property `name`.
  ###
  haveProperty: (name) ->
    assert.notEqual undefined, @target[name] unless @negate
    assert.equal undefined, @target[name] if @negate
    this

  ###
  Assert @target have property `length` of `len`.
  ###
  haveLength: (len) ->
    @haveProperty 'length'
    assert.equal @target.length, len unless @negate
    assert.notEqual @target.length, len if @negate
    this

  ###
  Assert @target to raise an error of the kind.
  ###
  raise: (error) ->
    try
      @target()
    catch e
      if not e instanceof error and not @negate
        assert.fail("Expected error of #{error} kind; got: #{e}")
      if @negate
        assert.fail("Unexpected error of #{error} kind.")
    this

# Common aliases...
(alias = (dict) ->
  for name, aliases of dict
    Expectation::[as] = Expectation::[name] for as in aliases
)
  beEqual: ['beEqualOf', 'beEqualTo' , 'be']
  beAnInstanceOf: ['beA']
  haveProperty: ['havePropertyOf', 'have']
  haveLength: ['haveLengthOf']
  raise: ['throw', 'throws']

###
Provides the DSL like feel to the user.

Examples::
  # Will throw `AssertionError`.
  expect(true).to :be: false

  # Will run as expected.
  dontExpect(true).to :be :false
###
Expectation::to = (directive) ->
  # Supports ``expect(object).to().beEqual(another)``.
  return this unless directive?

  possibilities = {}

  # Find all the methods pointed by the directive.
  method = new String
  while keys(directive).length isnt 0
    break unless typeof directive is 'object'
    for part, directive of directive
      method += if method.length is 0 then part else capitalize part
      possibilities[method] = directive if @[method]?

  if keys(possibilities).length is 0
    throw TypeError "No suitible directive found: #{inspect directive}"

  # Call the longest one of them.
  longest = (keys(possibilities).sort (lhs, rhs) ->
    lhs.length - rhs.length
  ).pop()

  @[longest](possibilities[longest])
 
###
Provide public access for monkey patching.
###
exports.Expectation = Expectation

###
Create an expectation for the `object`.
###
exports.expect = (object) ->
  new exports.Expectation object

###
Create an negated expectation for the `object`.
###
exports.dontExpect = (object) ->
  new exports.Expectation object, negate: true

