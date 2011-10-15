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
The internal strategy to call methods based on a dictionary directives.
###
explicitLookup = (options) ->
  [directive, object] = [options.for, options.in]
  directives = {}

  # Find all the methods pointed by the directive.
  method = new String
  for part, directive of directive
    method += if method.length is 0 then part else capitalize part
    directives[method] = directive if object[method]?

  return false if keys(directive).length is 0

  # Call the longest one of them.
  longest = (keys(directives).sort (lhs, rhs) ->
    rhs.length - lhs.length
  ).pop()

  object[longest](directives[longest])
  
###
The expectation object is responsible for the assertions behavior.
###
class Expectation
  constructor: (@target, options = {}) ->
    @negate = options.negate or false

  ###
  Assert @target to be equal to `other` object.
  ###
  be: (other) ->
    assert.equal @target, other unless @negate
    assert.notEqual @target, other if @negate
    this
  
  ###
  Alias to `be`.
  ###
  beEqual: (other) ->
    @be(other)

  beEqualOf: (other) ->
    @be(other)

  ###
  Assert @target to be an instance of `kind`.
  ###
  beA: (kind) ->
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

  if directive.be?
    {be: {equal, a}} = directive
    # Supports ``expect(object).to be: equal: another``.
    return @beEqual(equal) if equal?
    # Supports ``expect(object).to be: a: kind``.
    return @beA(a) if a?
  else if directive.have?
    {have: {property, length}} = directive
    # Supports ``expect(array).to :have :length 2``.
    return @haveLength(length) if length?
    # Supports ``expect(array).to :have :property 'length'``
    return @haveProperty(property) if property?
  else
    {raise} = directive
    # Supports ``expect(-> object).to raise: Error``
    return @raise(raise) if raise?

  return this if explicitLookup for: directive, in: this

  throw TypeError "No suitible directive found: #{inspect directive}"
 
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

