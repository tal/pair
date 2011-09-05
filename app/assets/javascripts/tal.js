window.Tal = new function Tal() {
  this.isArray = Array.isArray || function(obj) {
    return toString.call(obj) === '[object Array]';
  };
  this.isFunction = function(obj) {
    return !!(obj && obj.constructor && obj.call && obj.apply);
  };
};

(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Tal.Event = (function() {
    __extends(Event, Array);
    function Event() {
      var args, arr, func, key, opts, value, _i, _len, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = Event.defaults;
      for (key in _ref) {
        value = _ref[key];
        this[key] = value;
      }
      while (func = args.pop() && Tal.isFunction(func)) {
        this.unshift(func);
      }
      if (Tal.isArray(func)) {
        arr = func;
        for (_i = 0, _len = arr.length; _i < _len; _i++) {
          func = arr[_i];
          this.push;
        }
      }
      this.fired = false;
      if (opts = args.pop()) {
        for (key in opts) {
          value = opts[key];
          this[key] = value;
        }
      }
    }
    Event.defaults = {};
    Event.prototype.fire = function() {
      var args, func, ret, succ, _i, _len;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.fire_args = args;
      succ = true;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        func = this[_i];
        ret = func.apply(null, args);
        if (ret === false) {
          succ = ret;
        }
      }
      this.fired = true;
      if (this.once) {
        this.push = this._fire_the_args;
      }
      return succ;
    };
    Event.prototype._fire_the_args = function() {
      var arg, args, ret, succ, _i, _len;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      succ = true;
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        arg = args[_i];
        ret = arg.apply(null, this.fire_args);
        if (ret === false) {
          succ = ret;
        }
      }
      Array.prototype.push.apply(this, args);
      return succ;
    };
    Event.prototype.bind = function() {
      return this.push.apply(this, arguments);
    };
    return Event;
  })();
  Tal.popupEvent = function(name, type) {
    var _base, _base2;
    (_base = Tal.popupEvent._store)[name] || (_base[name] = {});
    return (_base2 = Tal.popupEvent._store[name])[type] || (_base2[type] = new Tal.Event({
      name: "popup_" + name + "_" + type
    }));
  };
  Tal.onPopupEvent = function(name, type, func) {
    return Tal.popupEvent(name, type).push(func);
  };
  Tal.popupEvent._store = {};
  Tal.Popup = (function() {
    var $body, i;
    Popup.defaults = {
      width: 774,
      overlayOpacity: 0.7,
      overlaySpeed: 500,
      closeSpeed: 200,
      closeAnimation: 'shrink',
      lock: true
    };
    Popup.$overlay = $("<div id='tal_popup_overlay'></div>").hide();
    Popup.$popups = $('<div id="tal_popups"></div>');
    $body = $();
    $(function() {
      $body = $('body');
      return $body.append(Popup.$overlay).append(Popup.$popups);
    });
    Popup.structure = "<div class=\"simple_popup\">\n  <div class=\"container\">\n    <a href=\"#\" class=\"close\"></a>\n  </div>\n\n</div>";
    Popup.find = {};
    Popup.s = [];
    i = 1;
    function Popup(args) {
      this.afterHideOverlay = __bind(this.afterHideOverlay, this);      if (args instanceof Popup) {
        return args;
      }
      this.name = (args != null ? args.name : void 0) || i++;
      this.args = $.extend({}, Popup.defaults, args);
      this.el = $(Popup.structure);
      this.el.width(this.args.width);
      if (this.name) {
        if (Popup.find[this.name]) {
          if (Tal.log) {
            console.error("There's already a popup of name " + this.name);
          }
          return Popup.find[this.name];
        }
        Popup.find[this.name] = this;
        this.el.attr('id', "tal_popup" + this.name);
      }
      this.active = false;
      this.body = $("<div class='content'></div>");
      this.el.find('.container').append(this.body);
      this.close_button = this.el.find('.close').click(__bind(function(e) {
        e.preventDefault();
        return this.x(e);
      }, this));
      this.button = this.el.find('.button').click(__bind(function(e) {
        e.preventDefault();
        return this.complete(e);
      }, this));
      if (this.args.body || this.args.html) {
        this.body.html(this.args.body || this.args.html);
      }
      if (this.args.text) {
        this.body.text(this.args.text);
      }
      if (this.args.url) {
        this.body.load(this.args.url);
      }
      this.el.hide();
      Popup.$popups.append(this.el);
      Popup.s.push(this);
    }
    Popup.prototype.hideOverlay = function() {
      return Popup.$overlay.fadeOut(this.args.overlaySpeed, this.afterHideOverlay);
    };
    Popup.prototype.afterHideOverlay = function() {
      $body.css({
        overflow: '',
        'padding-right': ''
      });
      return Popup.$popups.removeClass('active');
    };
    Popup.prototype.showOverlay = function() {
      var $o, origWidth;
      if (this.args.lock) {
        origWidth = $body.width();
        $o = Popup.$overlay.filter(':hidden');
        $o.show();
        $body.css({
          overflow: 'hidden'
        });
        $body.css({
          'padding-right': $body.width() - origWidth
        });
        $o.fadeTo(0, 0.0, __bind(function() {
          return $o.fadeTo(this.args.overlaySpeed, this.args.overlayOpacity);
        }, this));
      }
      return Popup.$popups.addClass('active');
    };
    Popup.prototype.getEvent = function(eventName) {
      var _name;
      if (Tal.popupEvent == null) {
        return;
      }
      return this[_name = "on" + eventName] || (this[_name] = this.name != null ? Tal.popupEvent(this.name, eventName) : new Tal.Event());
    };
    Popup.prototype.fireEvents = function(eventName) {
      var succ;
      succ = true;
      if ((typeof optimizely !== "undefined" && optimizely !== null) && (this.name != null)) {
        optimizely.trackEvent("popup_" + this.name + "_event_" + eventName);
      }
      if (Tal.popupEvent != null) {
        succ = this.getEvent(eventName).fire(this, eventName);
        Tal.popupEvent("all", eventName).fire(this, eventName);
      }
      if (typeof _gaq !== "undefined" && _gaq !== null) {
        _gaq.push(['_trackEvent', 'tal_popups', eventName, this.name]);
      }
      return succ;
    };
    Popup.prototype.show = function() {
      var args, callback, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.fireEvents('show');
      if (this.args.noClose) {
        this.close_button.hide();
      }
      animationName(_.isString(args[0]) ? args.shift() : this.args.openAnimation);
      callback = _.isFunction(args[0]) ? args.shift() : function() {};
      if (Popup._active) {
        Popup._active.close(true);
      } else {
        this.showOverlay();
      }
      try {
        if ((_ref = Tal.Popup.animations) != null ? _ref.open[animationName] : void 0) {
          Tal.Popup.animations.open[animationName](this.el, this.args, callback);
        } else {
          this.el.show();
          callback();
        }
      } catch (error) {
        if (Tal.log) {
          console.error(error);
        }
        this.el.show();
        callback();
      }
      this.active = true;
      Popup._active = this;
      return this;
    };
    Popup.prototype.complete = function() {
      return this.fireEvents('complete');
    };
    Popup.prototype.x = function() {
      this.fireEvents('x');
      return this.close.apply(this, arguments);
    };
    Popup.prototype.close = function() {
      var animationName, args, callback;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (this.fireEvents('close') === false) {
        return false;
      }
      if (args[0] === true) {
        args.shift();
      } else {
        this.hideOverlay();
      }
      animationName = _.isString(args[0]) ? args.shift() : this.args.closeAnimation;
      callback = _.isFunction(args[0]) ? args.shift() : function() {};
      try {
        if ((Tal.Popup.animations != null) && Tal.Popup.animations.close[animationName]) {
          Tal.Popup.animations.close[animationName](this.el, this.args, callback);
        } else {
          this.el.hide();
          callback();
        }
      } catch (error) {
        if (Tal.log) {
          console.error(error);
        }
        this.el.hide();
        callback();
      }
      this.active = false;
      Popup._active = null;
      if (this.group) {
        this.group.closing(this);
      }
      return this;
    };
    Popup.prototype.remove = function() {
      var idx;
      if (this.active) {
        this.close();
      }
      idx = Popup.s.indexOf(this);
      if (idx !== -1) {
        Popup.s.splice(idx, 1);
      }
      this.el.remove();
      return null;
    };
    return Popup;
  })();
  Tal.Popup.animations = {
    open: {
      drop: function(el, args, callback) {
        var speed, top;
        speed = args.openSpeed;
        top = el.css('top');
        el.css({
          top: el.outerHeight() * -1
        });
        el.show().animate({
          top: top
        }, speed, function() {
          el.css('top', '');
          return typeof callback === "function" ? callback() : void 0;
        });
        return el;
      },
      instant: function(el, args, callback) {
        el.show();
        if (typeof callback === "function") {
          callback();
        }
        return el;
      },
      slide: function(el, args, callback) {
        var left, speed;
        speed = args.openSpeed;
        left = (Tal.Popup.$popups.width() - el.width()) / 2;
        el.css({
          margin: 0,
          left: el.width() + Tal.Popup.$popups.width(),
          position: 'absolute'
        });
        el.show();
        el.animate({
          left: left
        }, speed, function() {
          el.css({
            margin: '0 auto',
            left: 0,
            position: ''
          });
          return typeof callback === "function" ? callback() : void 0;
        });
        return el;
      },
      shrink: function(el, args, callback) {
        var goto, pos, speed;
        speed = args.openSpeed;
        goto = {
          width: el.width(),
          height: el.height(),
          top: +el.css('top').replace('px', ''),
          opacity: 1
        };
        pos = {
          width: 0 + 'px',
          height: 0 + 'px',
          top: goto.top + (goto.height / 2) + 'px',
          opacity: 0
        };
        el.css(pos);
        el.show();
        el.animate(goto, speed, function() {
          if (typeof callback === "function") {
            callback();
          }
          return el.css('height', '');
        });
        return el;
      }
    },
    close: {
      drop: function(el, args, callback) {
        var speed;
        speed = args.openSpeed;
        el.animate({
          top: el.outerHeight() * -1
        }, speed, function() {
          el.hide().css('top', '');
          return typeof callback === "function" ? callback() : void 0;
        });
        return el;
      },
      instant: function(el, args, callback) {
        el.hide();
        if (typeof callback === "function") {
          callback();
        }
        return el;
      },
      slide: function(el, args, callback) {
        var speed;
        speed = args.closeSpeed;
        el.css({
          margin: 0,
          left: el.offset().left,
          position: 'absolute'
        });
        el.animate({
          left: ((el.width() - 50) * -1) + 'px'
        }, speed, function() {
          el.hide().css({
            margin: '0 auto',
            left: 0,
            position: ''
          });
          return typeof callback === "function" ? callback() : void 0;
        });
        return el;
      },
      shrink: function(el, args, callback) {
        var goto, pos, speed;
        speed = args.closeSpeed;
        pos = {};
        pos.width = el.width();
        pos.height = el.height();
        pos.top = +el.css('top').replace('px', '');
        pos.opacity = 1;
        el.css(pos);
        goto = {};
        goto.width = 0 + 'px';
        goto.height = 0 + 'px';
        goto.top = pos.top + (pos.height / 2) + 'px';
        goto.opacity = 0;
        el.animate(goto, speed, function() {
          if (typeof callback === "function") {
            callback();
          }
          el.css(pos).css('height', '');
          return el.hide();
        });
        return el;
      }
    }
  };
  Tal.PopupGroup = (function() {
    __extends(PopupGroup, Array);
    PopupGroup.defaults = {
      nextAnimation: 'slide',
      showAnimation: 'shrink'
    };
    function PopupGroup() {
      var args, popup, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.name = (_ref = args[0]) != null ? _ref.name : void 0;
      popup = args.pop();
      while (popup instanceof Tal.Popup) {
        this.add(popup);
        popup = args.pop();
      }
      if (Tal.isArray(popup)) {
        this.add.apply(this, popup);
        popup = args.pop();
      }
      this.args = $.extend({}, PopupGroup.defaults, popup || {});
      this.active = false;
    }
    PopupGroup.prototype.add = function() {
      var args, popup, _i, _len;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        popup = args[_i];
        popup = new Tal.Popup(popup);
        popup.group = this;
        Array.prototype.push.call(this, popup);
      }
      if (this.current == null) {
        this.current = this[0];
      }
      return this;
    };
    PopupGroup.prototype.push = PopupGroup.prototype.add;
    PopupGroup.prototype.shift = function() {
      var args, popup, _i, _len;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        popup = args[_i];
        popup = new Tal.Popup(popup);
        popup.group = this;
        Array.prototype.shift.call(this, popup);
      }
      if (this.current == null) {
        this.current = this[0];
      }
      return this;
    };
    PopupGroup.prototype.show = function() {
      var _ref;
      this.active = true;
      if ((_ref = this.current) != null) {
        _ref.show(this.args.showAnimation);
      }
      return this;
    };
    PopupGroup.prototype.close = function() {
      this.current.close(this.args.showAnimation);
      return this;
    };
    PopupGroup.prototype.closing = function(popup) {
      this.active = false;
      if (this.isLast(popup)) {
        return this.finish();
      }
    };
    PopupGroup.prototype.isLast = function(popup) {
      return this[this.length - 1] === popup;
    };
    PopupGroup.prototype.currentIndex = function() {
      return this.indexOf(this.current);
    };
    PopupGroup.prototype.next = function() {
      var next;
      if (this.current === this[0] && !this.active) {
        return this.show();
      }
      next = this[this.currentIndex() + 1];
      if (next == null) {
        return this.close();
      }
      console.log(this.current.name, next.name);
      this.current.close(true, this.args.nextAnimation);
      next.show(this.args.nextAnimation);
      this.current = next;
      return this;
    };
    PopupGroup.prototype.previous = function() {
      var prev;
      if (this.current === this[0]) {
        return this.hide();
      }
      prev = this[this.currentIndex() - 1];
      this.current.close(true, this.args.nextAnimation);
      prev.show(this.args.nextAnimation);
      this.current = prev;
      return this;
    };
    PopupGroup.prototype.finish = function() {};
    return PopupGroup;
  })();
}).call(this);
