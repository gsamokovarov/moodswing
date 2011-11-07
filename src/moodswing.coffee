# **Moodswing** uses [CoffeeScript](http://jashkenas.github.com/coffee-script/)
# to provide assertions which can look like English sentences.
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
# ``new Expectation([]).haveLengthOf(0)``.
#
# This means that the object ``have: length: of: 0``, which we call a
#  _directive_, is translated to a method named ``haveLengthOf`` using
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
#     {expect, dontExpect, Expectation} = require 'moodswing'
#
# The code is available on [github](http://github.com/gsamokovarov/moodswing)
# under MIT license. 

# ### Prerequisites

# Require `inspect` for prettier object printings.
{inspect} = require 'util'
# Require the standard [node](https://nodejs.org) assertion module for most of our _low level_
# assertions. This gives us the nice benefit to be able to run our tests on
# [expresso](http://visionmedia.github.com/expresso/).
assert = require 'assert'

# ### Internal utilities

# Before we begin we define some helpful utilities, which would be used
# through the project implementation.

# Primitive safe `Object.keys` implementation.
keys = (something) ->
  Object.keys(Object something)

# Capitalizes a string.
capitalize = (str) ->
  "#{str[0].toUpperCase()}#{str[1...]}"

# ### Public exports

# Now we start to implement the portion that would be exported to the user.

# The expectation object is responsible for the assertions behavior. All of the
# assertions pointed by the directives are living in its prototype.
class exports.Expectation
  constructor: (target, options = {}) ->
    @negate = options.negate or false
    Object.defineProperty @, 'target'
      get: ->
        return target unless typeof target is "function"
        target()

  # Assert `@target` to be equal to `other` object.
  beEqual: (other) ->
    unless @negate
      assert.equal @target, other
    else
      assert.notEqual @target, other
    this

  # Assert `@target` to be an instance of `kind`.
  beAnInstanceOf: (kind) ->
    unless @negate
      assert.ok @target instanceof kind, "Expected #{@target} to be an instance of #{kind}"
    else
      assert.ok !(@target instanceof kind), "Did not expected #{@target} to be and instance of #{kind}"
    this

  # Assert `@target` have a property `name`.
  haveProperty: (name) ->
    unless @negate
      assert.ok @target[name]?, "Expected property #{name} in #{inspect @target}"
    else
      assert.ok not @target[name]?, "Did not expected a property #{name} in #{inspect @target}"
    this

  # Assert `@target` have property `length` of `len`.
  haveLength: (len) ->
    @haveProperty 'length'
    unless @negate
      assert.equal @target.length, len
    else
      assert.notEqual @target.length, len
    this

  # Assert `@target` to raise an `error` of the kind.
  raise: (error) ->
    try
      @target
    catch e
      unless @negate
        assert.ok e instanceof error, "Expected error of #{error} kind; got: #{e}"
      else
        throw new assert.AssertionError "Did not expected an error of #{error} kind."
    this

# Used to define `Expectation.prototype` aliases. This is really useful because
# you can define the verbosity of the expectation, depending of the context.
exports.Expectation.alias = (dict) ->
  for name, aliases of dict
    exports.Expectation::[as] = exports.Expectation::[name] for as in aliases

# Parses a `directive` into a method call. Returns self if none given.
#
# A `directive` is an deep object of the kind ``be: equal: to: true`` which
# points to a camel cased method and a parameter to call it with. Since there
# can be more then one method matching a given `directive`, we will always call
# the longest one we match.
exports.Expectation::to = (directive) ->
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
    throw TypeError "No suitable directive found: #{inspect directive}"

  # Call the longest one of them.
  longest = (keys(possibilities).sort (lhs, rhs) ->
    lhs.length - rhs.length
  ).pop()

  @[longest](possibilities[longest])
 
# Create an expectation for the `target`. This is actually the main function
# that we'll be using. The `target`
exports.expect = (target) ->
  new exports.Expectation target

# Create an negated expectation for the `target`. The second most used function
# after `expect`.
exports.dontExpect = (target) ->
  new exports.Expectation target, negate: true

# Now we define some common aliases.
exports.Expectation.alias
  beEqual: ['beEqualOf', 'beEqualTo' , 'be']
  beAnInstanceOf: ['beInstanceOf', 'beA']
  haveProperty: ['havePropertyOf', 'have']
  haveLength: ['haveLengthOf']
  raise: ['throw', 'throws']

# Have fun.
