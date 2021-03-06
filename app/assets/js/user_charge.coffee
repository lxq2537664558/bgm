# 玩家充值Ctrl
app.controller "UserChargeCtrl", ["$scope", "$http", "$location", ($scope, $http, $location)->
	initUserCtrl($scope, $location, $http)
	$scope.menu = 'charge'
	unless $scope.user then getUserInfo($http, $scope, $scope.sid, $scope.uid)
	getRechargeInfo($http, $scope)
]

# 玩家设置Ctrl
app.controller "UserSettingCtrl", ["$scope", "$http", "$location", ($scope, $http, $location)->
	initUserCtrl($scope, $location, $http)
	$scope.menu = 'setting'
	$scope.roomName = roomName
	$scope.timeLongToString = timeLongToString

	unless $scope.user then getUserInfo($http, $scope, $scope.sid, $scope.uid)
	getUserSetting($http, $scope)
	$scope.alterModifyChat = alterModifyChat($scope)
	$scope.saveModifyChat = saveModifyChat($scope, $http)
	$scope.deleteChat = deleteChat($scope, $http)
	$scope.deleteSysMail = deleteSysMail($scope, $http)
	$scope.authLoginClick = authLoginClick($scope)
	$scope.authChatClick = authChatClick($scope)
]

# 获取充值信息
getRechargeInfo = ($http, $scope)->
	sid = $scope.sid 
	uid = $scope.uid
	$http.get("/json/gs/userCharge?sid=#{sid}&uid=#{uid}").success (data)->
		console.log "userChargeResp = ", data
		$scope.his = data.list
		$scope.uc = data.uc 

# 获取玩家聊天和邮件信息
getUserSetting = ($http, $scope)->
	sid = $scope.sid
	uid = $scope.uid
	$http.get("/json/gs/userSetting?sid=#{sid}&uid=#{uid}").success (data)->
		console.log "getUserSetting resp : ", data
		$scope.chats = data.chats or []
		$scope.sysMails = data.sysMails or []
		$scope.userMails = data.userMails or []
		$scope.base = data.base 
		# 登陆是否被限制
		$scope.userAuthForbiddenLogin = data.base.auth == 1 or false 
		$scope.userChatForbiddenLogin = data.base.authChat == 1 or false 
		$scope.userAuthForbiddenTime = timeLongToString(data.base.authTime)
		$scope.userChatForbiddenTime = timeLongToString(data.base.authChatTime)

# 弹出聊天修改框
alterModifyChat = ($scope)-> (index)->
	chat = $scope.chats[index]
	$scope.modifyChat = chat 
	$("#chatModal").modal('show')

# 保存聊天消息
saveModifyChat = ($scope, $http) -> ()->
	data = 
		sid: $scope.sid
		id: $scope.modifyChat.id
		msg: $scope.modifyChat.msg 
	$.post("/json/gs/updateChat", data, ()-> $("#chatModal").modal('toggle'))

#登陆权限提交按钮
authLoginClick = ($scope)-> ()->
	data = 
		sid: $scope.sid
		uid: $scope.uid
		login: $scope.userAuthForbiddenLogin
		loginTime: $scope.userAuthForbiddenTime
	$.post("/json/gs/forbiddenLogin", data, (data)-> console.log "forbiddenLogin resp ", data)

authChatClick = ($scope)-> ()->
	data = 
		sid: $scope.sid
		uid: $scope.uid
		chat: $scope.userChatForbiddenLogin
		chatTime: $scope.userChatForbiddenTime
	$.post("/json/gs/forbiddenChat", data, (data)-> console.log "forbiddenLogin resp ", data)

# 删除聊天消息
deleteChat = ($scope, $http)-> (index)->
	chat = $scope.chats[index]
	chats = $scope.chats
	$http.get("/json/gs/deleteChat?sid=#{$scope.sid}&id=#{chat.id}")
	$scope.chats = for c in chats when c.id != chat.id then c

deleteSysMail = ($scope, $http)-> (index)->
	sysMails = $scope.sysMails
	mail = sysMails[index]
	$http.get("/json/gs/deleteMail?sid=#{$scope.sid}&id=#{mail.id}")
	$scope.sysMails = for m in sysMails when m.id != mail.id then m

# 房间名
roomName = (room)-> ["全服", "私人", "军团"][room]