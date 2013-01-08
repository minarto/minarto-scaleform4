class com.minarto.data.ListDataBinding {
	public static function bind($t) {
		if ($t.__binds__)	return	$t;
		$t.__binds__ = [];
		$t.__bindHandler__ = Binding.prototype.bindHandler;
		$t.addBind = Binding.prototype.addBind;
		$t.delBind = Binding.prototype.delBind;
		
		return	$t;
	}
	
	
	private function bindHandler($p, $old, $new, $binds) {
		if ($old === $new)	return	$old;
		for (var i = 0, c = $binds.length; i < c; ++ i){
			$binds[i + 1][$binds[i]]($new);
		}
		
		return	$new;
	}
	
	
	private function addBind($key:String, $handler:String, $scope) {
		var a:Array = this["__binds__"];
		for (var i:Number = 0, c:Number = a.length; i < c; i += 2) {
			if (a[i] == $handler && a[i + 1] == $scope) {
				$scope[$handler](this[$key]);
				
				return	this;
			}
		}
		a.push($handler, $scope);
		
		this.watch($key, this["__bindHandler__"], a);
		
		$scope[$handler](this[$key]);
		
		return	this;
	}
	
	
	private function delBind($key:String, $handler:String, $handlerScope) {
		var a:Array = this["__binds__"];
		for (var i:Number = 0, c:Number = a.length; i < c; i += 2) {
			if (a[i] == $handler && a[i + 1] == $handlerScope) {
				a.splice(i, 2);
				return	this;
			}
		}
		
		return	this;
	}
}