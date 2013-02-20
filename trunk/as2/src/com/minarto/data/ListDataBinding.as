import com.minarto.data.*;


class com.minarto.data.ListDataBinding {
	public static function bind($t) {
		if ($t.__binds__)	return	$t;
		$t.__binds__ = {};
		$t.__bindHandler__ = ListDataBinding.prototype.bindHandler;
		$t.addBind = ListDataBinding.prototype.addBind;
		$t.delBind = ListDataBinding.prototype.delBind;
		
		return	$t;
	}
	
	
	private function bindHandler($p, $old, $new, $binds) {
		if ($old === $new)	return	$old;
		
		for ($p in $binds) {
			$old = $binds[$p];
			$old.scope[$old.handler]($new);
		}
		
		return	$new;
	}
	
	
	private function addBind($key:String, $scope, $handler:String) {
		var o = this["__binds__"];
		var binds = o[$key] || (o[$key] = []);
		
		for (var i in binds) {
			o = binds[i];
			if (o.scope == $scope) {
				o.handler = $handler;
				return;
			}
		}
		
		o = { scope:$scope, handler:$handler };
		binds.push(o);
		
		o = this["__bindHandler__"];
		this.watch($key, o, binds);
		
		return	this;
	}
	
	
	private function delBind($key:String, $scope, $handler:String) {
		var o = this["__binds__"];
		var binds = o[$key];
		if (binds) {
			if ($scope && $handler) {
				for (var i in binds) {
					o = binds[i];
					if (o.scope == $scope && o.handler == $handler) {
						binds.splice(i, 1);
						break;

					}
				}
				if (binds.length > 0) {
					this.unwatch($key);
					delete	this["__binds__"][$key];
				}
			}
			else {
				this.unwatch($key);
				delete	o[$key];
			}
		}
		else {
			delete	this.__binds__;
			delete	this.__bindHandler__;
			delete	this.addBind;
			delete	this.delBind;
		}
		
		return	this;
	}
}