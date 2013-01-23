import com.minarto.manager.list.*;


class com.minarto.manager.list.ListParam {
	// 리스트 타입
	public static var SOURCE_LIST:String = "sourceList";	//	실제 가지고 있는 아이템 (예 : 인벤토리, 스킬, 창고)
	public static var REFERENCE_LIST:String = "referenceList";	//	자기 것이 아닌 참조로만 존재하는 아이템 (예 : 상점, 경매장)
	public static var LINK_LIST:String = "linkList";	//	링크된 리스트 (예 : 퀵슬롯)
	
	
	//	소스 쪽에서 사용하는 옵션
	public var sumInclude:Boolean;	// 링크 쪽에 아이템 합계를 표현해야 하는 아이템들의 합에 포함한다(예 : true - 인벤토리, false - 창고, 스킬, 제작기술)

	
	//	링크 쪽에서 사용하는 옵션
	public var countBySum:Boolean = true;	//	같은 테이블 아이디를 가진 아이템들의 합을 표현 (예 : true - 퀵슬롯)
	
	
	
	//	 소스/링크 양쪽 다 사용하는 옵션
	public var linkEnabled:Boolean;	//	링크 가능 여부 (예 : true - 인벤토리, 퀵슬롯, false - 창고)
	public var listType:String = SOURCE_LIST;	//	리스트 타입 (예 : link - 퀵슬롯, 물약 슬롯, source - 인벤토리, 창고, 스킬, 제작기술)
	public var useEnable:Boolean;	//	사용 가능 여부 (예 : 트레이드 창)
	public var moveEnable:Boolean;	//	이동 가능 여부 (예 : link - 퀵슬롯, 물약 슬롯, source - 인벤토리, 창고, 스킬, 제작기술)
	public var moveEnableList = {};	//	링크 가능한 리스트 키 컨테이너  (예 : 퀵슬롯 - 인벤토리, 인벤토리 - 창고\인벤토리)
}