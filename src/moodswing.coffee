# **Moodswing** uses [CoffeeScript](http://jashkenas.github.com/coffee-script/)
# to provide assertions which can look like english sentences.
#
#     expect(true).to be: true
#     expect([]).to have: length: of: 0
#     dontExpect(-> null).to raise: Error
#     dontExpect('this').to be: equal: to: 'that'
#
# This is possible because of the
# [CoffeeScript](http://jashkenas.github.com/coffee-script/) object
# [literal](http://jashkenas.github.com/coffee-script/#literals) syntax. For
# example the line ``expect([]).to have: length: of: 0`` is equal to the call
# ``(new Expectation []).haveLengthOf(0)``.
#
# This means that the object ``have: length: of: 0``, which from now on I would
# call a _directive_, is translated to a method named ``haveLengthOf`` using
# camel case notation. This method is then looked for in the 
# ``Expectation.prototype`` and is being called with the _reminder_ of the 
# object.
#
# The ``Expectation`` constructor is publicly available, so you can augment its
# prototype with your own directives.
#
# You can install moodswing through [NPM](http://npmjs.org)
#
#     npm install moodswing
#
# To use moodswing just require it in your tests
#
#     {expect, dontExpect, Expectations} = require 'moodswing'
#
# The code is available on [github](http://github.com/gsamokovarov/moodswing)
# under MIT license. 

# ### Prerequisites

# We use `inspect` for prettier object printings.
{inspect} = require 'util'
# We use the standard `node` asserion module for most of our _low level_
# assertions. This gives us the nice benefit to be able to run our tests on
# (expresso)[http://visionmedia.github.com/expresso/].
assert = require 'assert'

# ### Inernals

# Primitive safe `Object.keys` implementation.
keys = (something) ->
  Object.keys(Object something)

# Takes the first object from an object or array named.
first = (it) ->
  return it[0] if Array.isArray(it) or typeof it is 'string'
  it[keys(it)[0]]

# Capitalizes a string.
capitalize = (str) ->
  "#{str[0].toUpperCase()}#{str[1...]}"

# ### Exports

# The expectation object is responsible for the assertions behavior. All of the
# assertions pointed by the directives are living in its constructor.
class Expectation
  constructor: (@target, options = {}) ->
    @negate = options.negate or false

  # Assert @target to be equal to `other` object.
  beEqual: (other) ->
    assert.equal @target, other unless @negate
    assert.notEqual @target, other if @negate
    this

  # Assert `@target` to be an instance of `kind`.
  beAnInstanceOf: (kind) ->
    unless @target instanceof kind
      assert.fail("Expected #{@target} to be an instance of #{kind}")
    this

  # Assert `@target` have a property `name`.
  haveProperty: (name) ->
    assert.notEqual undefined, @target[name] unless @negate
    assert.equal undefined, @target[name] if @negate
    this

  # Assert `@target` have property `length` of `len`.
  haveLength: (len) ->
    @haveProperty 'length'
    assert.equal @target.length, len unless @negate
    assert.notEqual @target.length, len if @negate
    this

  # Assert `@target` to raise an error of the kind.
  raise: (error) ->
    try
      @target()
    catch e
      if not e instanceof error and not @negate
        assert.fail("Expected error of #{error} kind; got: #{e}")
      if @negate
        assert.fail("Unexpected error of #{error} kind.")
    this

# Creates some common aliases...
(alias = (dict) ->
  for name, aliases of dict
    Expectation::[as] = Expectation::[name] for as in aliases
)
  beEqual: ['beEqualOf', 'beEqualTo' , 'be']
  beAnInstanceOf: ['beInstanceOf', 'beA']
  haveProperty: ['havePropertyOf', 'have']
  haveLength: ['haveLengthOf']
  raise: ['throw', 'throws']

# Parses a `directive` into a method call. Returns self if none given.
#
# A `directive` is an deep object of the kind ``be: equal: to: true`` which
# points to a camel cased method and a parameter to call it with. Since there
# can be more then one method matching a given `directive`, we will always call
# the longest one we match.
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
 
# Provide public access for monkey patching.
exports.Expectation = Expectation

# Create an expectation for the `target`. This is actually the main function
# that we'll be using. The `target`
exports.expect = (target) ->
  new exports.Expectation target

# Create an negated expectation for the `target`. The second most used function
# after `expect`.
exports.dontExpect = (target) ->
  new exports.Expectation target, negate: true

# Have fun.
