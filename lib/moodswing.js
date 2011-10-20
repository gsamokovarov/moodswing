var Expectation, alias, assert, capitalize, first, inspect, keys;
inspect = require('util').inspect;
assert = require('assert');
keys = function(something) {
  return Object.keys(Object(something));
};
first = function(it) {
  if (Array.isArray(it) || typeof it === 'string') {
    return it[0];
  }
  return it[keys(it)[0]];
};
capitalize = function(str) {
  return "" + (str[0].toUpperCase()) + str.slice(1);
};
Expectation = (function() {
  function Expectation(target, options) {
    this.target = target;
    if (options == null) {
      options = {};
    }
    this.negate = options.negate || false;
  }
  Expectation.prototype.beEqual = function(other) {
    if (!this.negate) {
      assert.equal(this.target, other);
    }
    if (this.negate) {
      assert.notEqual(this.target, other);
    }
    return this;
  };
  Expectation.prototype.beAnInstanceOf = function(kind) {
    if (!(this.target instanceof kind)) {
      assert.fail("Expected " + this.target + " to be an instance of " + kind);
    }
    return this;
  };
  Expectation.prototype.haveProperty = function(name) {
    if (!this.negate) {
      assert.notEqual(void 0, this.target[name]);
    }
    if (this.negate) {
      assert.equal(void 0, this.target[name]);
    }
    return this;
  };
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
  beAnInstanceOf: ['beInstanceOf', 'beA'],
  haveProperty: ['havePropertyOf', 'have'],
  haveLength: ['haveLengthOf'],
  raise: ['throw', 'throws']
});
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
exports.Expectation = Expectation;
exports.expect = function(target) {
  return new exports.Expectation(target);
};
exports.dontExpect = function(target) {
  return new exports.Expectation(target, {
    negate: true
  });
};