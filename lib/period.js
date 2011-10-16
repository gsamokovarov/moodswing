var AssertionError, Expectation, alias, assert, capitalize, first, inspect, keys;
inspect = require('util').inspect;
assert = require('assert');
AssertionError = assert.AssertionError;
/*
Primitive safe ``Object.keys`` implementation.
*/
keys = function(something) {
  return Object.keys(Object(something));
};
/*
Takes the first object from an object or array.
*/
first = function(it) {
  if (Array.isArray(it) || typeof it === 'string') {
    return it[0];
  }
  return it[keys(it)[0]];
};
/*
Capitalizes the string `str`.
*/
capitalize = function(str) {
  return "" + (str[0].toUpperCase()) + str.slice(1);
};
/*
The expectation object is responsible for the assertions behavior.
*/
Expectation = (function() {
  function Expectation(target, options) {
    this.target = target;
    if (options == null) {
      options = {};
    }
    this.negate = options.negate || false;
  }
  /*
    Assert @target to be equal to `other` object.
    */
  Expectation.prototype.beEqual = function(other) {
    if (!this.negate) {
      assert.equal(this.target, other);
    }
    if (this.negate) {
      assert.notEqual(this.target, other);
    }
    return this;
  };
  /*
    Assert @target to be an instance of `kind`.
    */
  Expectation.prototype.beAnInstanceOf = function(kind) {
    if (!(this.target instanceof kind)) {
      assert.fail("Expected " + this.target + " to be an instance of " + kind);
    }
    return this;
  };
  /*
    Assert @target have a property `name`.
    */
  Expectation.prototype.haveProperty = function(name) {
    if (!this.negate) {
      assert.notEqual(void 0, this.target[name]);
    }
    if (this.negate) {
      assert.equal(void 0, this.target[name]);
    }
    return this;
  };
  /*
    Assert @target have property `length` of `len`.
    */
  Expectation.prototype.haveLength = function(len) {
    this.haveProperty('length');
    if (!this.negate) {
      assert.equal(this.target.length, len);
    }
    if (this.negate) {
      assert.notEqual(this.target.length, len);
    }
    return this;
  };
  /*
    Assert @target to raise an error of the kind.
    */
  Expectation.prototype.raise = function(error) {
    try {
      this.target();
    } catch (e) {
      if (!e instanceof error && !this.negate) {
        assert.fail("Expected error of " + error + " kind; got: " + e);
      }
      if (this.negate) {
        assert.fail("Unexpected error of " + error + " kind.");
      }
    }
    return this;
  };
  return Expectation;
})();
(alias = function(dict) {
  var aliases, as, name, _results;
  _results = [];
  for (name in dict) {
    aliases = dict[name];
    _results.push((function() {
      var _i, _len, _results2;
      _results2 = [];
      for (_i = 0, _len = aliases.length; _i < _len; _i++) {
        as = aliases[_i];
        _results2.push(Expectation.prototype[as] = Expectation.prototype[name]);
      }
      return _results2;
    })());
  }
  return _results;
})({
  beEqual: ['beEqualOf', 'beEqualTo', 'be'],
  beAnInstanceOf: ['beA'],
  haveProperty: ['havePropertyOf', 'have'],
  raise: ['throw', 'throws']
});
/*
Provides the DSL like feel to the user.

Examples::
  # Will throw `AssertionError`.
  expect(true).to :be: false

  # Will run as expected.
  dontExpect(true).to :be :false
*/
Expectation.prototype.to = function(directive) {
  var longest, method, part, possibilities;
  if (directive == null) {
    return this;
  }
  possibilities = {};
  method = new String;
  while (keys(directive).length !== 0) {
    if (typeof directive !== 'object') {
      break;
    }
    for (part in directive) {
      directive = directive[part];
      method += method.length === 0 ? part : capitalize(part);
      if (this[method] != null) {
        possibilities[method] = directive;
      }
    }
  }
  if (keys(possibilities).length === 0) {
    throw TypeError("No suitible directive found: " + (inspect(directive)));
  }
  longest = (keys(possibilities).sort(function(lhs, rhs) {
    return lhs.length - rhs.length;
  })).pop();
  return this[longest](possibilities[longest]);
};
/*
Provide public access for monkey patching.
*/
exports.Expectation = Expectation;
/*
Create an expectation for the `object`.
*/
exports.expect = function(object) {
  return new exports.Expectation(object);
};
/*
Create an negated expectation for the `object`.
*/
exports.dontExpect = function(object) {
  return new exports.Expectation(object, {
    negate: true
  });
};