var AssertionError, Expectation, assert, capitalize, explicitLookup, first, inspect, keys;
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
The internal strategy to call methods based on a dictionary directives.
*/
explicitLookup = function(options) {
  var directive, directives, longest, method, object, part, _ref;
  _ref = [options["for"], options["in"]], directive = _ref[0], object = _ref[1];
  directives = {};
  method = new String;
  for (part in directive) {
    directive = directive[part];
    method += method.length === 0 ? part : capitalize(part);
    if (object[method] != null) {
      directives[method] = directive;
    }
  }
  if (keys(directive).length === 0) {
    return false;
  }
  longest = (keys(directives).sort(function(lhs, rhs) {
    return rhs.length - lhs.length;
  })).pop();
  return object[longest](directives[longest]);
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
  Expectation.prototype.be = function(other) {
    if (!this.negate) {
      assert.equal(this.target, other);
    }
    if (this.negate) {
      assert.notEqual(this.target, other);
    }
    return this;
  };
  /*
    Alias to `be`.
    */
  Expectation.prototype.beEqual = function(other) {
    return this.be(other);
  };
  Expectation.prototype.beEqualOf = function(other) {
    return this.be(other);
  };
  /*
    Assert @target to be an instance of `kind`.
    */
  Expectation.prototype.beA = function(kind) {
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
/*
Provides the DSL like feel to the user.

 Examples::
   # Will throw `AssertionError`.
   expect(true).to :be: false

   # Will run as expected.
   dontExpect(true).to :be :false
*/
Expectation.prototype.to = function(directive) {
  var a, equal, length, property, raise, _ref, _ref2;
  if (directive == null) {
    return this;
  }
  if (directive.be != null) {
    _ref = directive.be, equal = _ref.equal, a = _ref.a;
    if (equal != null) {
      return this.beEqual(equal);
    }
    if (a != null) {
      return this.beA(a);
    }
  } else if (directive.have != null) {
    _ref2 = directive.have, property = _ref2.property, length = _ref2.length;
    if (length != null) {
      return this.haveLength(length);
    }
    if (property != null) {
      return this.haveProperty(property);
    }
  } else {
    raise = directive.raise;
    if (raise != null) {
      return this.raise(raise);
    }
  }
  if (explicitLookup({
    "for": directive,
    "in": this
  })) {
    return this;
  }
  throw TypeError("No suitible directive found: " + (inspect(directive)));
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