import com.minarto.data.ListBinding;
import com.minarto.manager.list.*;
import gfx.events.EventDispatcher;


class com.minarto.manager.list.ListBridge extends EventDispatcher {
	private static var _instance:ListBridge;
		
		
	private var listDic = {}, keyParams = {}, coolTimeDataDic:Array = [], 
					keyCooltimeRate:String, keyCooltimeTotal:String, coolTimeDic = {}, coolTimeIDDic = {};
	
	
	public function ListBridge(){
		if(_instance)	throw	new Error("don't create instance");
		_instance = this;
	}
	
	
	public function setList($key:String, $a:Array):Void {
		var param:* = keyParams[$key];
		for(var i:* in $a){
			_setData(null, $a[i], param);
		}
		listDic[$key] = $a;
		ListBinding.setList($key, $a);
	}
	
	
	public function setDataProperty($data, $p:String, $value):Void {
		ListBinding.setDataProperty($data, $p, $value);
	}
	
	
	public function setData($target, $data, $index:Number):Void {
		ListBinding.setData($target, $data, $index);
	}
	
	
	private function _setData($oData, $nData, $param):Void{
		coolTimeDataDic[$nData] = {};
	}
	
	
	public function coolTimeKeyInit($keyCooltimeRate:String, $keyCooltimeTotal:String, $coolTimeInterval:Number):Void{
		keyCooltimeRate = $keyCooltimeRate;
		keyCooltimeTotal = $keyCooltimeTotal;
		
		var a:Array = arguments.slice(3, arguments.length);
		for(var i:* in a){
			coolTimeIDDic[a[i]] = {};
		}
		
		setInterval(function ():Void {
			var date:Date = new Date;
			var time:Number = date.getTime();
			
			for(var key:String in coolTimeDic){
				var typeObj = coolTimeDic[key];
				
				for(var keyValue:String in typeObj){
					var timeObj = typeObj[keyValue];
					
					var rate:Number = (typeObj.currentTime + (time - typeObj.startTime)) * typeObj.rate;
					var totalTime:Number = typeObj.totalTime;
					
					if(rate >= 1){
						rate = 1;
						for(i in coolTimeDataDic){
							var o = coolTimeDataDic[i];
							if(o.timeObj == timeObj){
								var d = o.data;
								ListBinding.setDataProperty(d, $keyCooltimeRate, rate);
								ListBinding.setDataProperty(d, $keyCooltimeTotal, totalTime);
								
								delete	o.timeObj;
							}
						}
						
						delete typeObj[keyValue];
					}
					else{
						for(i in coolTimeDataDic){
							o = coolTimeDataDic[i];
							if(o.timeObj == timeObj){
								d = o.data;
								ListBinding.setDataProperty(d, keyCooltimeRate, rate);
								ListBinding.setDataProperty(d, keyCooltimeTotal, totalTime);
							}
						}
					}
				}
			}
		}, $coolTimeInterval);
	}
	
	
	/**
	 * 
	 * @param $key
	 * @param $keyValue
	 * @param $currentTime
	 * @param $totalTime
	 * 
	 */
	public function setCoolTime($key:String, $keyValue:String, $currentTime:Number, $totalTime:Number):Void {
		var date:Date = new Date;
		
		var typeObj = coolTimeDic[$key] || (coolTimeDic[$key] = {});
		var timeObj = typeObj[$keyValue] || (typeObj[$keyValue] = {});
		
		timeObj.startTime = date.getTime();
		timeObj.currentTime = $currentTime;
		timeObj.totalTime = $totalTime;
		timeObj.rate = 1 / $totalTime;
		
		for(var p in coolTimeDataDic){
			var o = coolTimeDataDic[p];
			var d = o.data;
			if(d[$key] == $keyValue){
				var timeObj2 = o.timeObj;
				if(!timeObj2 || (timeObj.totalTime * timeObj.rate < timeObj2.totalTime * timeObj2.rate)){
					o.timeObj = timeObj;	//	남은 시간이 많은 쪽 쿨타임 객체를 적용
				}
			}
		}
	}
	
	
	public function addList($key:String, $param):Void{
		keyParams[$key] = $param;
	}
	
	
	public function delList($key:String):Void{
		if($key){
			delete	keyParams[$key];
		}
		else{
			keyParams = {};
		}
	}
}