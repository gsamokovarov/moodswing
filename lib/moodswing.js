var assert, capitalize, inspect, keys;

inspect = require('util').inspect;

assert = require('assert');

keys = function(something) {
  return Object.keys(Object(something));
};

capitalize = function(str) {
  return "" + (str[0].toUpperCase()) + str.slice(1);
};

exports.Expectation = (function() {

  function Expectation(target, options) {
    if (options == null) options = {};
    this.negate = options.negate || false;
    Object.defineProperty(this, 'target', {
      get: function() {
        if (typeof target !== "function") return target;
        return target();
      }
    });
  }

  Expectation.prototype.beEqual = function(other) {
    if (!this.negate) {
      assert.equal(this.target, other);
    } else {
      assert.notEqual(this.target, other);
    }
    return this;
  };

  Expectation.prototype.beStrictly = function(other) {
    if (!this.negate) {
      assert.strictEqual(this.target, other);
    } else {
      assert.notStrictEqual(this.target, other);
    }
    return this;
  };

  Expectation.prototype.beDeeply = function(other) {
    if (!this.negate) {
      assert.deepEqual(this.target, other);
    } else {
      assert.notDeepEqual(this.target, other);
    }
    return this;
  };

  Expectation.prototype.beAnInstanceOf = function(kind) {
    if (!this.negate) {
      assert.ok(this.target instanceof kind, "Expected " + this.target + " to be an instance of " + kind);
    } else {
      assert.ok(!(this.target instanceof kind), "Did not expected " + this.target + " to be and instance of " + kind);
    }
    return this;
  };

  Expectation.prototype.haveProperty = function(name) {
    if (!this.negate) {
      assert.ok(this.target[name] != null, "Expected property " + name + " in " + (inspect(this.target)));
    } else {
      assert.ok(!(this.target[name] != null), "Did not expected a property " + name + " in " + (inspect(this.target)));
    }
    return this;
  };

  Expectation.prototype.haveLength = function(len) {
    this.haveProperty('length');
    if (!this.negate) {
      assert.equal(this.target.length, len);
    } else {
      assert.notEqual(this.target.length, len);
    }
    return this;
  };

  Expectation.prototype.raise = function(error) {
    try {
      this.target;
    } catch (e) {
      if (!this.negate) {
        assert.ok(e instanceof error, "Expected error of " + error + " kind; got: " + e);
      } else {
        throw new assert.AssertionError("Did not expected an error of " + error + " kind.");
      }
    }
    return this;
  };

  return Expectation;

})();

exports.Expectation.alias = function(dict) {
  var aliases, as, name, _results;
  _results = [];
  for (name in dict) {
    aliases = dict[name];
    _results.push((function() {
      var _i, _len, _results2;
      _results2 = [];
      for (_i = 0, _len = aliases.length; _i < _len; _i++) {
        as = aliases[_i];
        _results2.push(exports.Expectation.prototype[as] = exports.Expectation.prototype[name]);
      }
      return _results2;
    })());
  }
  return _results;
};

exports.Expectation.prototype.to = function(directive) {
  var longest, method, part, possibilities;
  if (directive == null) return this;
  if (directive.to != null) {
    throw new TypeError("Can not start a directive with 'to'");
  }
  possibilities = {};
  method = new String;
  while (keys(directive).length !== 0) {
    if (typeof directive !== 'object') break;
    for (part in directive) {
      directive = directive[part];
      method += method.length === 0 ? part : capitalize(part);
      if (this[method] != null) possibilities[method] = directive;
    }
  }
  if (keys(possibilities).length === 0) {
    throw TypeError("No suitable directive found: " + (inspect(directive)));
  }
  longest = (keys(possibilities).sort(function(left, right) {
    return left.length - right.length;
  })).pop();
  return this[longest](possibilities[longest]);
};

exports.expect = function(target) {
  return new exports.Expectation(target);
};

exports.dontExpect = function(target) {
  return new exports.Expectation(target, {
    negate: true
  });
};

exports.Expectation.alias({
  beEqual: ['beEqualOf', 'beEqualTo', 'be'],
  beStrictly: ['beStrictlyEqualOf', 'beStrictlyEqualTo', 'beStrictlyEqual'],
  beDeeply: ['beDeeplyEqualOf', 'beDeeplyEqualTo', 'beDeeplyEqual'],
  beAnInstanceOf: ['beInstanceOf', 'beA'],
  haveProperty: ['havePropertyOf', 'have'],
  haveLength: ['haveLengthOf'],
  raise: ['throw', 'throws']
});