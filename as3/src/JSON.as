/*
Copyright (c) 2005 JSON.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
wwww.designvox.com 에 있는 as2용 코드를 as3 용으로 바꿈
*/

package {
	public class JSON {
		public static function stringify(arg:*):String {
			var c:*, i:*, l:String, s:String = '', v:*;
			
			switch (typeof arg) {
				case 'object':
					if (arg) {
						if (arg as Array) {
							for (i = 0; i < arg.length; ++i) {
								v = stringify(arg[i]);
								if (s) {
									s += ',';
								}
								s += v;
							}
							return '[' + s + ']';
						} else if (typeof arg.toString != 'undefined') {
							for (i in arg) {
								v = arg[i];
								if (typeof v != 'undefined' && typeof v != 'function') {
									v = stringify(v);
									if (s) {
										s += ',';
									}
									s += stringify(i) + ':' + v;
								}
							}
							return '{' + s + '}';
						}
					}
					return 'null';
				case 'number':
					return isFinite(arg) ? String(arg) : 'null';
				case 'string':
					l = arg.length;
					s = '"';
					for (i = 0; i < l; i += 1) {
						c = arg.charAt(i);
						if (c >= ' ') {
							if (c == '\\' || c == '"') {
								s += '\\';
							}
							s += c;
						} else {
							switch (c) {
								case '\b':
									s += '\\b';
									break;
								case '\f':
									s += '\\f';
									break;
								case '\n':
									s += '\\n';
									break;
								case '\r':
									s += '\\r';
									break;
								case '\t':
									s += '\\t';
									break;
								default:
									c = c.charCodeAt();
									s += '\\u00' + Math.floor(c / 16).toString(16) +
									(c % 16).toString(16);
							}
						}
					}
					return s + '"';
				case 'boolean':
					return String(arg);
				default:
					return 'null';
			}
		}
		
		public static function parse(text:String):* {
			var at:uint = 0;
			var ch:String = ' ';
			var _value:Function;
			
			var _error:Function = function (m:String):void {
				throw {
					name: 'JSONError',
					message: m,
					at: at - 1,
						text: text
				};
			}
			
			var _next:Function = function():String {
				ch = text.charAt(at);
				at += 1;
				return ch;
			}
			
			var _white:Function = function():void {
				while (ch) {
					if (ch <= ' ') {
						_next();
					} else if (ch == '/') {
						switch (_next()) {
							case '/':
								while (_next() && ch != '\n' && ch != '\r') {}
								break;
							case '*':
								_next();
								for (;;) {
									if (ch) {
										if (ch == '*') {
											if (_next() == '/') {
												_next();
												break;
											}
										} else {
											_next();
										}
									} else {
										_error("Unterminated comment");
									}
								}
								break;
							default:
								_error("Syntax error");
						}
					} else {
						break;
					}
				}
			}
			
			var _string:Function = function():String {
				var i:uint, s:String = '', t:int, u:int;
				var outer:Boolean = false;
				
				if (ch == '"') {
					while (_next()) {
						if (ch == '"') {
							_next();
							return s;
						} else if (ch == '\\') {
							switch (_next()) {
								case 'b':
									s += '\b';
									break;
								case 'f':
									s += '\f';
									break;
								case 'n':
									s += '\n';
									break;
								case 'r':
									s += '\r';
									break;
								case 't':
									s += '\t';
									break;
								case 'u':
									u = 0;
									for (i = 0; i < 4; i += 1) {
										t = parseInt(_next(), 16);
										if (!isFinite(t)) {
											outer = true;
											break;
										}
										u = u * 16 + t;
									}
									if(outer) {
										outer = false;
										break;
									}
									s += String.fromCharCode(u);
									break;
								default:
									s += ch;
							}
						} else {
							s += ch;
						}
					}
				}
				_error("Bad string");
				
				return	null;
			}
			
			var _array:Function = function():Array {
				var a:Array = [];
				
				if (ch == '[') {
					_next();
					_white();
					if (ch == ']') {
						_next();
						return a;
					}
					while (ch) {
						a.push(_value());
						_white();
						if (ch == ']') {
							_next();
							return a;
						} else if (ch != ',') {
							break;
						}
						_next();
						_white();
					}
				}
				_error("Bad array");
				
				return	a;
			}
			
			var _object:Function = function():* {
				var k:String, o:* = {};
				
				if (ch == '{') {
					_next();
					_white();
					if (ch == '}') {
						_next();
						return o;
					}
					while (ch) {
						k = _string();
						_white();
						if (ch != ':') {
							break;
						}
						_next();
						o[k] = _value();
						_white();
						if (ch == '}') {
							_next();
							return o;
						} else if (ch != ',') {
							break;
						}
						_next();
						_white();
					}
				}
				_error("Bad object");
			}
			
			var _number:Function = function():Number {
				var n:* = '', v:Number;
				
				if (ch == '-') {
					n = '-';
					_next();
				}
				while (ch >= '0' && ch <= '9') {
					n += ch;
					_next();
				}
				if (ch == '.') {
					n += '.';
					while (_next() && ch >= '0' && ch <= '9') {
						n += ch;
					}
				}
				//v = +n;
				v = 1 * n;
				if (!isFinite(v)) {
					_error("Bad number");
				}
				return v;
			}
			
			var _word:Function = function():Boolean {
				switch (ch) {
					case 't':
						if (_next() == 'r' && _next() == 'u' && _next() == 'e') {
							_next();
							return true;
						}
						break;
					case 'f':
						if (_next() == 'a' && _next() == 'l' && _next() == 's' &&
							_next() == 'e') {
							_next();
							return false;
						}
						break;
					case 'n':
						if (_next() == 'u' && _next() == 'l' && _next() == 'l') {
							_next();
							return false;
						}
						break;
				}
				_error("Syntax error");
				return false;
			}
			
			_value = function():* {
				_white();
				switch (ch) {
					case '{':
						return _object();
					case '[':
						return _array();
					case '"':
						return _string();
					case '-':
						return _number();
					default:
						return ch >= '0' && ch <= '9' ? _number() : _word();
				}
			}
			
			return _value();
		}
	}
}