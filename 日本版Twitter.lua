local task = {}
local script = require("script")
local tool = require("tool")
function task.run(info, log)
	local index = 0
	local userDataType = "HotmailData"
	if (not getUserData(info, log, userDataType)) then
		return true, "请求用户数据超时，本轮任务结束"
	end
	while (true) do
		::continue::
		tool.unkeepScreen()	
		--检测脚本版本是否有变化，可视情况定制间隔时长调用以下函数
		if (script.versionChanged(info)) then return true, "脚本版本变化，任务重启" end
		--检测任务是否超时，可视情况定制间隔时长调用以下函数
		if (script.timeout(start, info)) then return true, "任务超时结束" end
		--检测任务是否闪退，可视情况定制间隔时长调用以下函数
		script.isAppQuit(info)
		--任务执行脚本
		--todo执行任务
		tool.keepScreen()
		if Run_App() then goto continue end  --运行应用
		if Sign_Up(info) then goto continue end  --开始注册
		if Youxianghefa() then goto continue end --邮箱是否被注册
		if VerityMail_old(info) then goto continue end --旧的邮箱验证码
		if VerityMail_new(info) then goto continue end --新的邮箱验证码
		if Follow() then goto continue end  --关注操作
		if Tweet() then goto continue end  --发推文
		if comment_retweet() then goto continue end --转推和评论
		if Other() then goto continue end --其他页面
--    如果有结束条件，请按下面的格式写脚本，跳出主循环，就可以执行下面的 return true, "任务成功" 了
--    if (canEndTask()) then break end
	end
	tool.unkeepScreen()	
	return true, "任务成功"
	--return false, "失败原因"
end

function getUserData(info, log, userDataType)
	local start=tool.time()
	while (true) do
		local result = tool.decode(tool.post("获取" .. userDataType .. "数据", info.domain .. "/api/udata/query", {logid = log.id, type = userDataType, scope = info.task.userDataScope, filter = ""}))
		if (result.success) then
			info.userData = result.data
			if next(info.userData) == nil then
				tool.dlg("数据无法获取为空",2)
				return false
			end
			tool.alert("当前状态:" .. log.status .. ",用户数据成功，开始任务")
			return true
		elseif(result.data == "当前留存未使用数据") then
			tool.alert(result.data,10)
			return false
		else
			if (result.data == "当前类型" .. userDataType .. "无可用数据") then
				local t = (tool.time() - start)
				if (t > 30) then
					tool.alert("请求用户数据" .. userDataType .. "超时，本轮任务结束")
					return false
				end
			end
			tool.alert("获取用户数据内部错误：" .. result.data .. "，稍后重试", 2)
		end
	end
end

function Run_App()
	local same=false
	local x,y=-1,-1
	if tool.isFrontApp("com.atebits.Tweetie2") then
		--发生问题，重试一次，关闭app
		x,y=tool.findColor({
				{  147,  627, 0x666666},
				{  165,  624, 0x858686},
				{  174,  626, 0x515151},
				{  185,  627, 0x535353},
				{  188,  623, 0x525252},
				{  205,  634, 0x565757},
				{  225,  627, 0x565757},
				{  231,  633, 0x141415},
				},90,{136, 604, 617, 677})
		if x>0 then
			tool.alert("哎呀，发生错误了。")
			tool.closeApp("com.atebits.Tweetie2")
		end
		--开始界面  はじめる
		x,y=tool.findColor({
				{  310,  767, 0x30a9f3},
				{  310,  775, 0x91d1f9},
				{  314,  777, 0xbae2fb},
				{  323,  780, 0x1da1f2},
				{  324,  778, 0x8ccff8},
				{  346,  770, 0x53b8f5},
				{  364,  764, 0x83cbf8},
				{  385,  777, 0x8ccff8},
				},90,{257, 714, 496, 831})
		if x>0 then
			tool.alert("这是日本版Twitter,はじめる")
			tool.tap(x,y,2)
		end
		--开始界面  アカウントを作成  有个小火箭
		x,y=tool.findColor({
				{  321,  704, 0x9bd5f9},
				{  323,  699, 0x99d5f9},
				{  349,  708, 0x6fc3f7},
				{  358,  718, 0x7dc9f7},
				{  387,  722, 0x78c7f7},
				{  423,  712, 0x78c7f7},
				{  426,  706, 0x82cbf8},
				{  460,  713, 0x98d4f9},
				},90,{232, 652, 521, 780})
		if x>0 then
			tool.alert("这是日本版Twitter,アカウントを作成")
			tool.tap(x,y,2)
		end
		--不关联通讯录，选择第二个
		x,y=tool.findColor({
				{  278,  697, 0x66bff6},
				{  291,  700, 0x40b0f4},
				{  290,  694, 0x91d1f9},
				{  298,  694, 0x91d1f9},
				{  345,  812, 0x4cb5f5},
				{  416,  822, 0x90d1f9},
				{  411,  830, 0xc9e8fc},
				{  433,  822, 0x73c5f7},
				},90,{243, 658, 519, 844})
		if x>0 then
			tool.alert("不关联通讯录，选择第二个",1)
			tool.tap(368,  816,2)
		end

	end
	return same
end

function Sign_Up(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'maxechrbtndymgbpz@hotmail.com',x2 = 'Iy6SOY36EW2X',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--输入Name
	x,y=tool.findColor({
			{   97,  392, 0xb9c1c8},
			{   90,  401, 0x657786},
			{   99,  405, 0xb2bbc3},
			{   99,  410, 0x8d9aa5},
			{  108,  406, 0xc4cbd0},
			{  116,  399, 0x7e8d99},
			{  123,  402, 0xa5b0b8},
			{  119,  391, 0x657786},
			},90,{72, 372, 167, 449})
	if x>0 then
		tool.alert("Name",1)
		tool.tap(304,  405,1)
		while(true) do
			if info.userData.x3 == nil or info.userData.x4 == nil or info.userData.x3 == "" or info.userData.x4 == "" then
				tool.dlg("获取的数据不存在或为空",2)
			else
				break
			end
		end
		tool.pasteText(info.userData.x4.." "..info.userData.x3)
	end
	--切换到输入Mail
	x,y=tool.findColor({
			{  269,  521, 0x657786},
			{  263,  535, 0x93a0aa},
			{  285,  529, 0x8b98a3},
			{  293,  517, 0x657786},
			{  408,  517, 0x657786},
			{  420,  528, 0x657786},
			{  431,  534, 0xa2adb6},
			{  455,  529, 0x677987},
			},90,{187, 483, 489, 572})
	if x>0 then
		tool.alert("切换到输入Mail",1)
		tool.tap(235,  531,1)
	end
	--由电话切换到邮箱
	x,y=tool.findColor({
			{  120,  891, 0x1b95e0},
			{  118,  892, 0x72bdec},
			{  124,  879, 0x1b95e0},
			{  453,  850, 0x1b95e0},
			{  446,  844, 0x73beec},
			{  450,  838, 0x7ac1ed},
			{  416,  826, 0x279be2},
			{  345,  839, 0xb8def5},
			},90,{24, 812, 475, 897})
	if x>0 then
		tool.alert("由电话切换到邮箱",1)
		tool.tap(x,y,1)
	end
	--输入邮箱
	x,y=tool.findColor({
			{   98,  518, 0xf2f4f5},
			{   93,  528, 0x657786},
			{   98,  534, 0xb7c0c7},
			{  112,  527, 0x657786},
			{  125,  526, 0x8997a2},
			{  149,  527, 0xa5afb8},
			{  141,  523, 0x657786},
			{  139,  534, 0x8d9aa5},
			},90,{79, 504, 186, 582})
	if x>0 then
		tool.alert("输入邮箱",1)
		tool.tap(174,  529,1)
		while(true) do
			if info.userData.x1 == nil or info.userData.x1== "" then
				tool.dlg("获取的数据不存在",2)
			else
				break
			end
		end
		tool.pasteText(info.userData.x1)
	end
	--输入Password
	x,y=tool.findColor({
			{   53,  343, 0x687a88},
			{   56,  345, 0xa9b3bc},
			{   58,  342, 0x677987},
			{   68,  343, 0x657786},
			{   71,  344, 0x7f8e9a},
			{   78,  357, 0x82919d},
			{   83,  362, 0x778794},
			{  165,  346, 0xc3cad0},
			},90,{36, 324, 190, 403})
	if x>0 then
		tool.alert("输入Password",1)
		tool.tap(149,  355,2)
		while(true) do
			if info.userData.x2 == nil or info.userData.x2== "" then
				tool.dlg("获取的数据不存在或为空",2)
			else
				break
			end
		end
		tool.pasteText(info.userData.x2)
	end
	return same
end

function Youxianghefa()
	local same=false
	local x,y=-1,-1
	x,y=tool.findColor({
			{  646,  518, 0xe0245e},
			{  647,  538, 0xe0245e},
			{  625,  527, 0xe0245e},
			{  666,  521, 0xe85c88},
			{  668,  530, 0xe0245e},
			{  654,  545, 0xf1a0ba},
			{  627,  578, 0xe0245e},
			{  650,  579, 0xe0245e},
			},90,{604, 485, 676, 695})
	if x>0 then
		tool.alert("邮箱已经被使用",2)
	end
	x,y=tool.findColor({
			{  627,  390, 0x17bf63},
			{  645,  377, 0x17bf63},
			{  667,  392, 0x17bf63},
			{  650,  397, 0x17bf63},
			{  642,  507, 0x8fe0b4},
			{  631,  542, 0x17bf63},
			{  643,  532, 0x20c269},
			{  665,  537, 0x17bf63},
			},90,{586, 342, 708, 598})
	if x>0 then
		tool.alert("邮箱合法，下一步",1)
		tool.tap(631,  857,5)--点击蓝色按钮
	end
	--确认Name和Mail
	x,y=tool.findColor({
			{  325, 1134, 0x60bdf6},
			{  330, 1139, 0x94d2f9},
			{  331, 1147, 0x1da1f2},
			{  332, 1153, 0x3caef4},
			{  353, 1137, 0x1da1f2},
			{  352, 1134, 0x6bc1f7},
			{  365, 1140, 0x9dd6f9},
			{  362, 1153, 0x22a3f2},
			},90,{278, 1056, 458, 1235})
	if x>0 then
		tool.alert("确认Name和Mail",2)
		tool.tap(x,y,15)
	end
	--验证密码是否合法
	x,y=tool.findColor({
			{  684,  355, 0x17bf63},
			{  688,  359, 0x17bf63},
			{  699,  345, 0x17bf63},
			{  708,  337, 0x17bf63},
			{  690,  396, 0xccd6dd},
			{  680,  369, 0x17bf63},
			{  669,  353, 0x17bf63},
			{  708,  366, 0x17bf63},
			},90,{659, 324, 727, 407})
	if x>0 then
		tool.alert("密码验证通过，下一步。",1)
		tool.tap(637,  857,5)
	end
	--确认密码按钮下去了
	x,y=tool.findColor({
			{  681, 1282, 0x7cc8f7},
			{  680, 1282, 0xa0d8fa},
			{  652, 1291, 0x9ad5f9},
			{  649, 1299, 0x9fd7fa},
			{  656, 1293, 0xf4fbfe},
			{  662, 1288, 0x63bef6},
			{  676, 1290, 0x96d3f9},
			{  688,  358, 0x17bf63},
			},90,{586, 288, 744, 1330})
	if x>0 then
		tool.alert("下一步",1)
		tool.tap(678, 1292,5)
	end
	return same
end

function VerityMail_old(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'maxechrbtndymgbpz@hotmail.com',x2 = 'Iy6SOY36EW2X',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--这是需要点击OK的界面  识别这个ok
	x,y=tool.findColor({
			{   64,  475, 0x45b2f4},
			{   63,  471, 0x95d3f9},
			{   66,  466, 0x1fa2f2},
			{   71,  466, 0x2ba7f3},
			{   74,  472, 0xc2e5fc},
			{   86,  469, 0x7dc9f7},
			{   88,  473, 0x75c5f7},
			{   81,  475, 0x9ed6f9},
			},90,{9, 337, 171, 654})
	if x>0 then
		tool.alert("找到OK按钮"..x.." "..y,2)
		tool.tap(x,y,3)
	end
	--we sent you a code(四行文字)  识别次へ
	x,y=tool.findColor({
			{   62,  612, 0x7ac8f7},
			{   74,  610, 0x72c4f7},
			{   77,  610, 0x72c4f7},
			{   75,  616, 0xa1d8fa},
			{   77,  623, 0xa2d8fa},
			{   74,  623, 0x84ccf8},
			{   98,  616, 0x31a9f3},
			{  112,  626, 0x85ccf8},
			},90,{4, 321, 314, 786})
	if x>0 then
		tool.alert("找到次へ按钮"..x.." "..y,2)
		tool.alert("开始获取验证码",3)
		url = "http://47.75.197.115:10004/getcode?username="..info.userData.x1.."&password="..info.userData.x2.."&sent_from=verify@twitter.com&code_re=\\d{6}+(?=</td>)"
		res = getCode("获取激活验证码", url)
		if (res ~= "") then
			tool.alert(res,2)
			tool.alert("去掉后面的空格",1)
			res=string.sub(res,1,6)
			tool.alert(res,2)
			tool.tap(115,y-120,2)
			tool.pasteText("")
			tool.pasteText(res)
			tool.tap(x,y,5)  --点击次へ按钮
		end
	end
	return same
end

function VerityMail_new(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'maxechrbtndymgbpz@hotmail.com',x2 = 'Iy6SOY36EW2X',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	x,y=tool.findColor({
			{   40,  214, 0x14171a},
			{   39,  223, 0x8a8b8d},
			{   44,  231, 0x727476},
			{   43,  243, 0x5f6163},
			{   59,  226, 0x14171a},
			{   88,  220, 0x14171a},
			{  111,  217, 0x14171a},
			{  126,  217, 0x606264},
			},90,{21, 193, 541, 262})
	if x>0 then
		tool.alert("开始获取验证码",3)
		tool.alert("准备输入验证码",2)
		url = "http://47.75.197.115:10004/getcode?username="..info.userData.x1.."&password="..info.userData.x2.."&sent_from=verify@twitter.com&code_re=\\d{6}+(?=</td>)"
		res = getCode("获取激活验证码", url)
		if (res ~= "") then
			tool.alert(res,2)
			tool.alert("去掉后面的空格",1)
			res=string.sub(res,1,6)
			tool.alert(res,2)
			tool.tap(242,  456,2)
			tool.pasteText("")
			tool.pasteText(res)
			tool.tap(666,  853,5)  --点击确认蓝色按钮
		end	
	end
	return same
end

function getCode(name, url)
	local cnt = 0
	while (true) do
		local c, h, b = tool.httpGet(url)
		if (c == 200) then
			return b
		else
			cnt = cnt + 1
			tool.alert("请求" .. name .. "数据，网络出错，代码：" .. c .. "，稍后重试", 3)
		end
		if (cnt > 10) then
			tool.dlg("当前获取数据10次失败，不获取了", 1)
			return ""
		end
	end
end

function Follow()
	local same=false
	local x,y=-1,-1
	--关注页面
	x,y=tool.findColor({
			{  391,  205, 0x14171a},
			{  374,  185, 0x14171a},
			{  299,  189, 0x14171a},
			{  214,  203, 0x14171a},
			{  169,  203, 0x14171a},
			{   91,  203, 0xffffff},
			{   46,  215, 0x14171a},
			{  684,  269, 0x14171a},
			},90,{25,  178,713,  319})
	if x~=-1 and y~=-1 then
		Point = {
			{{{  545,  464, 0x1da1f2},{  519,  495, 0x1da1f2},{  540,  492, 0xffffff},{  532,  500, 0xffffff},{  532,  520, 0x1da1f2},{  579,  492, 0x1da1f2},{  597,  492, 0xffffff},{  602,  493, 0xffffff}},508,  434,725, 1243,1,90,"关注"},
		}
		local x, y = -1, -1
		for i, v in ipairs(Point) do
			x, y = tool.findColor(v[1], v[7],{ v[2], v[3], v[4], v[5]})
			if x > 0 then
				tool.alert("找到关注按钮"..x.." "..y,1)
				tool.tap(x,y)
				tool.sleep(2)
				same=true
			else
				tool.alert("寻找完成",1)
				tool.tap(636, 1291)
				tool.sleep(10)
				tool.closeApp("com.atebits.Tweetie2")
			end
		end	
	end
	return same
end

function Tweet()
	local same=false
	local x,y=-1,-1
	--发推按钮正下方，准备发推文
	x,y=tool.findColor({
			{  364, 1260, 0xa5d9fa},
			{  353, 1260, 0xa5d9fa},
			{  354, 1263, 0xa5d9fa},
			{  359, 1267, 0xd2ecfc},
			{  362, 1267, 0x77c7f7},
			{  398, 1251, 0xbee4fb},
			{  382, 1267, 0x7fcaf8},
			{  363, 1289, 0xd1ecfc},
			},90,{287, 1193, 464, 1332})
	if x>0 then
		tool.alert("发推按钮正下方，准备发推文",1)
		tool.tap(x,y,2)
	end
	--Twitter主页 发推按钮在右上角
	x,y=tool.findColor({
			{  334,   86, 0x14171a},
			{  343,   71, 0x14171a},
			{  364,   82, 0x14171a},
			{  403,   71, 0x14171a},
			{  415,   89, 0x14171a},
			{  679,   70, 0x1da1f2},
			{  714,   68, 0x1da1f2},
			{  696,   82, 0x1da1f2},
			},90,{320,   57,725,  110})
	if x>0 then
		tool.alert("发推按钮在右上角，准备发推文",1)
		tool.tap(697,   82,2)
	end
	--Twitter主页 发推按钮在右下角
	x,y=tool.findColor({
			{  654, 1153, 0xd2ecfc},
			{  648, 1149, 0xa5d9fa},
			{  650, 1146, 0xa5d9fa},
			{  661, 1146, 0xa5d9fa},
			{  693, 1136, 0x6fc3f7},
			{  668, 1153, 0xb9e2fb},
			{  659, 1177, 0x85ccf8},
			{  665, 1157, 0x48b3f4},
			},90,{633, 1122, 711, 1192})
	if x>0 then
		tool.alert("发推按钮在右下角，准备发推文",1)
		tool.tap(672, 1142,2)
	end
	--Twitter主页 发推按钮在右下角
	x,y=tool.findColor({
			{  332,   78, 0x525456},
			{  346,   78, 0x545658},
			{  344,   89, 0x404345},
			{  654, 1156, 0xc3e6fc},
			{  657, 1152, 0x77c7f7},
			{  657, 1145, 0x4ab4f5},
			{  688, 1148, 0xe1f2fd},
			{  673, 1146, 0x22a3f2},
			},90,{309, 41, 713, 1198})
	if x>0 then
		tool.alert("发推按钮在右下角，准备发推文",1)
		tool.tap(672, 1142,2)
	end
	--发推文界面
	x,y=tool.findColor({
			{   45,   72, 0x1da1f2},
			{   66,   95, 0x1da1f2},
			{  589,   80, 0xf4fafe},
			{  597,   82, 0xc8e8fc},
			{  605,   76, 0xfcfeff},
			{  623,   88, 0xddf1fd},
			{  647,   82, 0xe9f6fe},
			{  670,   86, 0xd6eefd},
			},90,{22, 35, 735, 132})
	if x>0 then
		tool.alert("这是发推文界面",1)
		local rs = ""
		for i=1,8,1 do
			rs = rs..string.char(math.random(97,122))
		end
		tool.pasteText("Hi~welecome to twitter."..rs)
	end
	--发推按钮变蓝就点击发推
	x,y=tool.findColor({
			{  590,   75, 0x73c5f7},
			{  592,   79, 0x60bdf6},
			{  598,   76, 0x76c6f7},
			{  640,   82, 0xc0e5fb},
			{  653,   85, 0xaeddfa},
			{  670,   84, 0x77c7f7},
			{  670,   94, 0x8ccff8},
			{  685,   86, 0x89cef8},
			},90,{548, 39, 722, 132})
	if x>0 then
		tool.alert("发推按钮变蓝了，发推吧",1)
		tool.tap(x,y,2)
		tool.move(336, 1180, 2, 340, 140, 0)
		tool.sleep(2)
	end
	return same
end

function comment_retweet()
	local same=false
	local x,y=-1,-1
	x,y=tool.findColor({
			{   93, 1265, 0x1da1f2},
			{   78, 1293, 0x6cc2f7},
			{   88, 1289, 0x33aaf4},
			{  100, 1284, 0x7bc8f8},
			{  298, 1301, 0x657786},
			{  453, 1296, 0x9ca8b2},
			{  661, 1282, 0x93a0ab},
			{  649, 1282, 0x657786},
			},90,{33, 1235, 708, 1322})
	if x>0 then
		tool.unkeepScreen()
		tool.keepScreen()
		--找转推按钮
		Point={
			{{{  317,  841, 0xffffff},{  306,  830, 0x657786},{  300,  835, 0x9aa6b0},{  310,  836, 0x9aa6b0},{  315,  854, 0x98a4ae},{  334,  847, 0x939faa},{  324,  847, 0x8a98a3},{  326,  831, 0x657786}},274, 38, 368, 1232,1,90,"找到转推按钮"},
		}
		local x,y=-1,-1
		for i,v in ipairs(Point) do
			x,y=tool.findColor(v[1], v[7], {v[2], v[3], v[4], v[5]})
			if x>0 then
				tool.alert("找到转推按钮"..x.." "..y,1)
				tool.tap(x,y,2)--点击转推按钮
				tool.tap(297, 1024,2)--点击转推文字
				tool.move(336, 1180, 2, 340,  140, 0)
				tool.sleep(2)
			end
		end
		tool.unkeepScreen()
		--找评论按钮
		tool.keepScreen()
		Point={
			{{{  170,  839, 0xffffff},{  168,  853, 0x85939f},{  167,  849, 0xa4afb8},{  158,  846, 0x657786},{  157,  833, 0x697a89},{  168,  827, 0x9ca7b1},{  171,  829, 0xa1acb5},{  181,  841, 0x7f8e9b}},136, 40, 210, 1238,1,90,"找到评论按钮"},
		}
		local x,y=-1,-1
		for i,v in ipairs(Point) do
			x,y=tool.findColor(v[1], v[7], {v[2], v[3], v[4], v[5]})
			if x>0 then
				tool.alert("找到评论按钮"..x.." "..y,1)
				tool.tap(x,y,2)
			end
		end
		tool.unkeepScreen()
	end
	--评论
	x,y=tool.findColor({
			{   46,   71, 0xb2dffb},
			{   55,   80, 0xb2dffb},
			{   62,   74, 0xb2dffb},
			{  641,   77, 0xdef1fd},
			{  641,   89, 0xe2f3fd},
			{  653,   82, 0xdbf0fd},
			{  656,   78, 0xe2f3fd},
			{  676,   90, 0xcceafc},
			},90,{25, 41, 723, 139})
	if x>0 then
		tool.alert("这是评论界面",1)
		local rs = ""
		for i=1,8,1 do
			rs = rs..string.char(math.random(97,122))
		end
		tool.pasteText("GLHF,nice,very nice.."..rs)
	end
	--评论按钮变蓝就点击
	x,y=tool.findColor({
			{  641,   78, 0x1ea1f2},
			{  652,   78, 0xa1d8fa},
			{  655,   84, 0xa9dbfa},
			{  653,   95, 0xb4e0fb},
			{  669,   92, 0x69c1f6},
			{  678,   90, 0x57b9f5},
			{  678,   80, 0x97d4f9},
			{  672,   74, 0x9ed7f9},
			},90,{601, 40, 723, 125})
	if x>0 then
		tool.alert("评论按钮变蓝了，评论吧",1)
		tool.tap(x,y,3)
		tool.move(336, 1180, 2, 340,  140, 0)
		tool.sleep(2)
	end
	return same
end

function Other()
	local same=false
	local x,y=-1,-1
	--发推失败，保存到草稿,点击OK
	x,y=tool.findColor({
			{  286,  678, 0x77b6fc},
			{  299,  680, 0x88bffb},
			{  295,  690, 0x007aff},
			{  357,  867, 0x79b6fa},
			{  375,  868, 0x78b6fa},
			{  384,  867, 0xa8cef8},
			{  394,  874, 0x268dfd},
			{  398,  857, 0x8cc0f9},
			},90,{257, 640, 499, 903})
	if x>0 then
		tool.alert("OK",1)
		tool.tap(375,  866,2)
	end
	--不小心进了别人的主页
	x,y=tool.findColor({
			{   46,   71, 0xb2dffb},
			{   34,   84, 0xb2dffb},
			{   44,   94, 0xb2dffb},
			{  319,   78, 0x2d3032},
			{  325,   80, 0x4d4f52},
			{  331,   85, 0x2e3033},
			{  334,   79, 0x333639},
			{  346,   87, 0x4b4e50},
			},90,{13, 43, 459, 117})
	if x>0 then
		tool.alert("不小心进了别人的主页",1)
		tool.tap(31,   82,2)
	end
	--不小心点了一个链接
	x,y=tool.findColor({
			{   39,   71, 0x36acf4},
			{   54,   80, 0xb2dffb},
			{   61,   94, 0xb2dffb},
			{  688,   73, 0x75c6f8},
			{  696,   70, 0x8dd0f9},
			{  699,   87, 0x8ed0f9},
			{  705,   75, 0x75c6f8},
			{  698,   66, 0x1da1f2},
			},90,{19, 47, 739, 119})
	if x>0 then
		tool.alert("不小心点了一个链接",1)
		tool.tap(54,   82,2)
	end
	--出现错误
	x,y=tool.findColor({
			{  363,  752, 0x007aff},
			{  353,  764, 0x037cff},
			{  364,  775, 0x007aff},
			{  374,  763, 0x007aff},
			{  381,  764, 0x007aff},
			{  398,  775, 0x027bff},
			{  397,  752, 0x097fff},
			{  389,  762, 0x087fff},
			},90,{297, 721, 453, 807})
	if x~=-1 and y~=-1 then
		tool.tap(x, y, 2)
		tool.closeApp("com.atebits.Tweetie2")
	end
	--上传头像   跳过
	x,y=tool.findColor({
			{  101,  408, 0x1da1f2},
			{  255,  394, 0x1da1f2},
			{  332,  485, 0x1da1f2},
			{  311,  620, 0x1da1f2},
			{  138,  671, 0x1da1f2},
			{  187,  505, 0x1da1f2},
			{  202,  498, 0xf0f1f3},
			{  183,  512, 0xf0f1f3},
			},90,{26,  366, 351,  701})
	if x~=-1 and y~=-1 then
		tool.alert("跳过上传头像",1)
		tool.tap(167, 1292,2)
	end
	x,y=tool.findColor({
			{   53,  417, 0x787a7c},
			{  427,  540, 0x14171a},
			{  294,  543, 0x14171a},
			{  444,  552, 0xffffff},
			{  369,  661, 0x1da1f2},
			{  363,  734, 0x1da1f2},
			{  368,  829, 0x1da1f2},
			{  673,  474, 0x14171a},
			},90,{40,  402,721,  853})
	if x~=-1 and y~=-1 then
		tool.alert("选择第二个",1)
		tool.tap(356,  820,2)
	end
	--what are you interested in?
	x,y=tool.findColor({
			{   41,  184, 0xb0b1b2},
			{   36,  208, 0x808183},
			{   41,  245, 0x14171a},
			{  132,  197, 0x14171a},
			{  314,  187, 0xffffff},
			{  379,  189, 0x14171a},
			{  617,  190, 0x14171a},
			{  669,  184, 0x14171a},
			},90,{26,  170,714,  288})
	if x~=-1 and y~=-1 then
		tool.alert("选择兴趣,跳过",1)
		tool.tap(93, 1289,2)
		tool.alert("5秒后开始寻找关注按钮",5)	
	end
	--个性化定制  Personalize sua experience
	x,y=tool.findColor({
			{  374,   79, 0x1da1f2},
			{  229,  187, 0x14171a},
			{  151,  316, 0x14171a},
			{  689,  307, 0x14171a},
			{  608,  189, 0x14171a},
			{  479,  322, 0xffffff},
			{  280,  321, 0xffffff},
			{  103,  360, 0x14171a},
			},90,{26,   51,703,  385})
	if x~=-1 and y~=-1 then
		tool.alert("个性化定制",1)
		tool.tap(655, 1290,2)
	end
	--允许通知
	x,y=tool.findColor({
			{  204,  455, 0x14171a},
			{  267,  473, 0x14171a},
			{  272,  473, 0xffffff},
			{  359,  470, 0x14171a},
			{  482,  474, 0xffffff},
			{  534,  460, 0x14171a},
			{  363,  658, 0x1da1f2},
			{  450,  828, 0x1da1f2},
			},90,{49,  433,718,  857})
	if x~=-1 and y~=-1 then
		tool.alert("不允许通知",1)
		tool.tap(357,  830,3)--不允许通知
	end
	--位置许可
	x,y=tool.findColor({
			{  483,  557, 0x414141},
			{  489,  560, 0x000000},
			{  465,  553, 0x000000},
			{  465,  550, 0x666666},
			{  469,  563, 0x383939},
			{  476,  577, 0x545454},
			{  481,  568, 0x3d3d3d},
			{  497,  561, 0x616262},
			},90,{345, 509, 628, 641})
	if x>0 then
		tool.alert("不允许使用位置",2)
		tool.tap(251,  785,2)
	end
	x,y=tool.findColor({
			{  379,   74, 0x1da1f2},
			{  336,  733, 0x1da1f2},
			{  632,  765, 0x1da1f2},
			{  144,  773, 0x1da1f2},
			{  391,  807, 0x1da1f2},
			{  332,  765, 0xffffff},
			{  380,  765, 0xffffff},
			{  428,  900, 0x1da1f2},
			},90,{57,   52,702,  939})
	if x>0 then
		tool.alert("同意协议",1)
		tool.tap(364,  903,2)
	end	
	--退出左滑菜单栏
	x,y=tool.findColor({
			{  101,  111, 0x657786},
			{  108,  151, 0x657786},
			{   90,  155, 0x657786},
			{  140,  117, 0xccd6dd},
			{  562,  106, 0xacddfb},
			{  575,  102, 0x4bb4f5},
			{  590,  102, 0x78c7f8},
			{  595,  104, 0x7fcaf8},
			},90,{25, 50, 626, 182})
	if x>0 then
		tool.alert("退出左滑菜单栏",2)
		tool.tap(694,   93,2)
	end
	--退出视频播放
	x,y=tool.findColor({
			{   35, 1086, 0xffffff},
			{   37, 1102, 0xffffff},
			{   45, 1086, 0x000000},
			{   42, 1099, 0x000000},
			{  103, 1095, 0xffffff},
			{  162, 1097, 0x333333},
			{  246, 1097, 0x333333},
			{  432, 1097, 0x333333},
			},90,{20, 1058, 560, 1131})
	if x>0 then
		tool.alert("退出视频播放",1)
		tool.tap(63,   74,2)
	end
	--点到视频了
	x,y=tool.findColor({
			{   61,   76, 0xcbcbcb},
			{   61,   75, 0xcbcbcb},
			{   66,   75, 0xcbcbcb},
			{   66,   76, 0xcbcbcb},
			{   91, 1242, 0x333334},
			{  108, 1242, 0x333334},
			{  290, 1096, 0x333334},
			{  348, 1096, 0x333334},
			},90,{22, 28, 726, 1318})
	if x>0 then
		tool.alert("点到视频了")
		tool.tap(65,   74,2)
	end
	--发推失败，点击OK
	x,y=tool.findColor({
			{  356,  869, 0x007aff},
			{  357,  869, 0x9ac6f8},
			{  373,  865, 0x007aff},
			{  373,  874, 0x007aff},
			{  382,  870, 0x007aff},
			{  381,  861, 0x007aff},
			{  384,  862, 0xbed8f6},
			{  398,  879, 0x7bb7f9},
			},90,{294, 357, 460, 1081})
	if x>0 then
		tool.alert("点击OK",1)
		tool.tap(x,y,2)
	end
	return same
end

return task