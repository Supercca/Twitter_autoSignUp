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
		if VerityMail_new(info) then goto continue end --新的邮箱验证码
		if VerityMail_old(info) then goto continue end --旧的邮箱验证码
		if Follow() then goto continue end  --关注操作
		if Tweet() then goto continue end  --发推文
		if comment_retweet() then goto continue end --转推和评论
		if Other() then goto continue end --关闭误点击页面
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
		x,y=tool.findColor({
				{  356,  574, 0xebebeb},
				{  356,  575, 0x0a0a0a},
				{  359,  587, 0x000000},
				{  361,  587, 0xebebec},
				{  359,  598, 0x000000},
				{  359,  599, 0xebeced},
				{  367,  599, 0xe8e9ea},
				{  368,  598, 0x000000},
				},90,{314, 556, 433, 618})
		if x~=-1 and y~=-1 then
			tool.alert("ERROR, 重启APP",3)
			tool.tap(378, 764, 2)
			tool.closeApp("com.atebits.Tweetie2")
			return true
		end
		x,y=tool.findColor({
				{  259,  688, 0x1da1f2},
				{  260,  689, 0xe6f5fe},
				{  260,  688, 0x66bff6},
				{  276,  698, 0x20a2f2},
				{  276,  701, 0xffffff},
				{  306,  702, 0x57b9f5},
				{  307,  702, 0xffffff},
				{  311,  700, 0x1da1f2},
				},90,{221, 621, 540, 907})
		if x~=-1 and y~=-1 then
			tool.alert("土耳其版本twitter现在开始1",1)
			tool.tap(x, y,2)
			return true
		end
		x,y=tool.findColor({
				{  332,  754, 0x1da1f2},
				{  332,  755, 0x66bff6},
				{  332,  756, 0xe6f5fe},
				{  335,  760, 0xffffff},
				{  336,  760, 0xafdefa},
				{  337,  760, 0x1da1f2},
				{  411,  768, 0x1da1f2},
				{  411,  769, 0x69c1f6},
				{  411,  770, 0xffffff},
				},90,{221, 621, 540, 907})
		if x~=-1 and y~=-1 then
			tool.alert("土耳其版本twitter现在开始2",1)
			tool.tap(x, y,2)
			return true
		end
	end
	return same
end

function Sign_Up(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'davidllnaslbz@hotmail.com',x2 = 'UYLyx8d57016',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--输入Name
	x,y=tool.findColor({
			{  103,  389, 0x657786},
			{  102,  400, 0x657786},
			{   89,  400, 0x657786},
			{   91,  408, 0x667886},
			{  128,  396, 0x657786},
			{  111,  443, 0x657786},
			{  120,  405, 0x7a8a97},
			{  113,  405, 0xffffff},
			},90,{58,  367,190,  451})
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
			{  173,  531, 0x8a98a3},
			{  175,  537, 0x8997a2},
			{  197,  530, 0x95a1ab},
			{  208,  530, 0x7d8c99},
			{  220,  541, 0xb4bdc4},
			{  242,  530, 0x8c99a4},
			{  243,  525, 0x8b99a4},
			{  266,  530, 0x7d8c99},
			},90,{99, 499, 380, 564})
	if x>0 then
		tool.alert("切换到输入Mail",1)
		tool.tap(235,  531,1)
	end
	--由电话切换到邮箱
	x,y=tool.findColor({
			{   45,  846, 0x1b95e0},
			{   60,  860, 0x1b95e0},
			{   42,  868, 0x3da5e5},
			{   99,  859, 0xffffff},
			{  132,  852, 0x1b95e0},
			{  171,  861, 0x1c95e0},
			{  204,  859, 0x1b95e0},
			{  219,  858, 0x1b95e0},
			},90,{19,  822,279,  889})
	if x>0 then
		tool.alert("由电话切换到邮箱",1)
		tool.tap(x,y,1)
	end
	--输入邮箱
	x,y=tool.findColor({
			{   90,  518, 0x657786},
			{   90,  527, 0x657786},
			{   90,  537, 0x657786},
			{  101,  529, 0x657786},
			{  118,  529, 0xffffff},
			{  135,  529, 0xffffff},
			{  149,  529, 0x657786},
			{  181,  527, 0x657786},
			},90,{69,  496,215,  582})
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
			{   41,  366, 0xaab4bc},
			{   46,  359, 0x6a7b8a},
			{   53,  352, 0x657786},
			{   53,  342, 0x657786},
			{   55,  355, 0xbbc3ca},
			{   63,  349, 0xa0abb4},
			{   72,  349, 0x85939f},
			{   84,  354, 0x657786},
			},90,{24, 314, 149, 397})
	if x>0 then
		tool.alert("输入Password",1)
		tool.tap(149,  355,1)
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
			{  329, 1133, 0x7fcaf8},
			{  325, 1152, 0x52b7f5},
			{  332, 1146, 0x7fcaf8},
			{  341, 1133, 0x99d5f9},
			{  347, 1143, 0x8bcff8},
			{  352, 1151, 0x1da1f2},
			{  367, 1157, 0xa3d9fa},
			{  373, 1142, 0xaeddfa},
			},90,{281, 1074, 456, 1217})
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
	--确认密码按钮到下面去了
	x,y=tool.findColor({
			{  684,  356, 0x19c065},
			{  690,  357, 0x17bf63},
			{  698,  344, 0x17bf63},
			{  692,  373, 0x17bf63},
			{  648, 1265, 0x1da1f2},
			{  661, 1265, 0x1da1f2},
			{  676, 1266, 0x1da1f2},
			{  686, 1266, 0x1da1f2},
			},90,{588, 290, 736, 1326})
	if x>0 then
		tool.alert("确认密码按钮到下面去了",1)
		tool.tap(637, 1286,5)
	end
	return same
end

function VerityMail_old(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'davidllnaslbz@hotmail.com',x2 = 'UYLyx8d57016',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--这是需要点击Tamam的界面  识别这个Tamam
	x,y=tool.findColor({
			{   60,  453, 0xbde3fb},
			{   64,  463, 0xaeddfa},
			{   79,  465, 0x1da1f2},
			{   93,  464, 0xa5d9fa},
			{  123,  463, 0x90d1f9},
			{  141,  455, 0x79c7f7},
			{  118,  455, 0x94d2f9},
			{   99,  455, 0x92d2f9},
			},90,{14, 286, 247, 612})
	if x>0 then
		tool.alert("找到Tamam按钮"..x.." "..y,2)
		tool.tap(x,y,3)
	end
	--we sent you a code(三行文字)  识别ileri
	x,y=tool.findColor({
			{   61,  568, 0x6ac1f6},
			{   64,  588, 0x67bff6},
			{   71,  586, 0xa5d9fa},
			{   81,  583, 0x1da1f2},
			{   84,  589, 0x6bc1f7},
			{   93,  579, 0x88cef8},
			{  101,  591, 0x72c4f7},
			{  105,  586, 0xa5d9fa},
			},90,{9, 372, 270, 775})
	if x>0 then
		tool.alert("找到ileri按钮"..x.." "..y,2)
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
			tool.tap(x,y,5)  --点击ileri按钮
		end
	end
	return same
end

function VerityMail_new(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'davidllnaslbz@hotmail.com',x2 = 'UYLyx8d57016',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	x,y=tool.findColor({
			{  343,  215, 0xe7e7e8},
			{  344,  216, 0x14171a},
			{  357,  223, 0xedeeee},
			{  356,  224, 0x14171a},
			{  353,  239, 0xffffff},
			{  355,  241, 0x14171a},
			{  437,  231, 0xffffff},
			{  439,  233, 0x14171a},
			},90,{298, 198, 571, 267})
	if x>0 then
		tool.alert("准备输入验证码",2)
		url = "http://47.75.197.115:10004/getcode?username="..info.userData.x1.."&password="..info.userData.x2.."&sent_from=verify@twitter.com&code_re=\\d{6}+(?=</td>)"
		res = getCode("获取激活验证码", url)
		if (res ~= "") then
			tool.alert(res,2)
			tool.alert("去掉后面的空格",1)
			res=string.sub(res,1,6)
			tool.alert(res,2)
			tool.tap(x,y,2)
			tool.pasteText("")
			tool.pasteText(res)
			tool.tap(624,  855,5)  --点击确认蓝色按钮
		end	
	end
	return same
end

function Follow()
	local same=false
	local x,y=-1,-1
	--关注页面
	x,y=tool.findColor({
			{  562,  194, 0x15181b},
			{  552,  209, 0x14171a},
			{  533,  201, 0xffffff},
			{  503,  186, 0x1d2023},
			{  502,  204, 0x14171a},
			{  464,  199, 0xc9c9ca},
			{  369,   82, 0x1da0f1},
			{  405,  202, 0xffffff},
			},90,{27,   45,573,  228})
	if x~=-1 and y~=-1 then
		Point = {
			{{{  597,  485, 0x5abaf6},{  640,  484, 0x21a3f2},{  652,  495, 0xffffff},{  677,  493, 0xffffff},{  665,  465, 0xf9fdff},{  652,  525, 0x1da1f2},{  689,  490, 0x1da1f2},{  670,  497, 0x1da1f2}},558,  433,724, 1243,1,90,"关注"},
		}
		local x, y = -1, -1
		for i, v in ipairs(Point) do
			x, y = tool.findColor(v[1], v[7],{ v[2], v[3], v[4], v[5]})
			if x > 0 then
				tool.alert("找到关注按钮"..x.." "..y)
				tool.tap(x,y)
				tool.sleep(2)
			else
				tool.alert("寻找完成")
				tool.tap(672, 1289)
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
			{  677,   73, 0xffffff},
			{  678,   74, 0x2fa9f4},
			{  680,   76, 0x1da1f2},
			{  682,   78, 0xffffff},
			{  706,   83, 0x20a3f3},
			{  708,   83, 0xffffff},
			{  682,  106, 0x44b1f5},
			{  683,  107, 0xffffff},
			},90,{614, 40, 741, 141})
	if x>0 then
		tool.alert("发推按钮在右上角，准备发推文")
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
		tool.alert("发推按钮在右下角，准备发推文")
		tool.tap(672, 1142,2)
	end
	--发推文界面
	x,y=tool.findColor({
			{   47,   75, 0x1da1f2},
			{   64,   92, 0x1da1f2},
			{  590,   77, 0xcbe9fc},
			{  631,   84, 0xbbe2fb},
			{  646,   82, 0xbbe2fb},
			{  661,   82, 0xdef1fd},
			{  667,   80, 0xd1ecfc},
			{  682,   84, 0xbbe2fb},
			},90,{23, 41, 726, 122})
	if x>0 then
		tool.alert("这是发推文界面")
		local rs = ""
		for i=1,8,1 do
			rs = rs..string.char(math.random(97,122))
		end
		tool.pasteText("Hi~welecome to twitter."..rs)
	end
	--发推按钮变蓝就点击发推
	x,y=tool.findColor({
			{  674,   86, 0xb0defa},
			{  667,   81, 0x66bff6},
			{  667,   75, 0x66bff6},
			{  680,   83, 0x1da1f2},
			{  648,   81, 0xadddfa},
			{  631,   85, 0xe6f5fe},
			{  627,   87, 0x95d3f9},
			{  616,   89, 0x76c6f7},
			},90,{542, 41, 729, 126})
	if x>0 then
		tool.alert("发推按钮变蓝了，发推吧")
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
			{  600,   75, 0xd1ecfc},
			{  623,   88, 0xbbe2fb},
			{  636,   87, 0xdaeffd},
			{  653,   89, 0xdaeffd},
			{  661,   88, 0xdef1fd},
			{  680,   88, 0xbbe2fb},
			{   49,   75, 0x20a3f3},
			{   61,   90, 0x1da1f2},
			},90,{27, 40, 723, 119})
	if x>0 then
		tool.alert("这是评论界面")
		local rs = ""
		for i=1,8,1 do
			rs = rs..string.char(math.random(97,122))
		end
		tool.pasteText("GLHF,nice,very nice.."..rs)
	end
	--评论按钮变蓝就点击
	x,y=tool.findColor({
			{  601,   74, 0xc2e5fc},
			{  608,   82, 0x9bd5f9},
			{  623,   88, 0x1da1f2},
			{  636,   87, 0x84ccf8},
			{  653,   85, 0x84ccf8},
			{  661,   77, 0x93d2f9},
			{  680,   90, 0x1da1f2},
			{  671,   88, 0x9dd6f9},
			},90,{562, 40, 732, 129})
	if x>0 then
		tool.alert("评论按钮变蓝了，评论吧")
		tool.tap(x,y,3)
		tool.move(336, 1180, 2, 340,  140, 0)
		tool.sleep(2)
	end
	return same
end

function Other()
	local same=false
	local x,y=-1,-1
	--不小心点击别人的主页
	x,y=tool.findColor({
			{   46,   69, 0x1da1f2},
			{   37,   74, 0xb2dffb},
			{   29,   85, 0xb9e2fb},
			{   39,   95, 0xb2dffb},
			{  324,   74, 0x888a8b},
			{  331,   88, 0x727476},
			{  337,   88, 0x8b8c8e},
			{  359,   81, 0x14171a},
			},90,{17, 55, 435, 112})
	if x>0 then
		tool.alert("这是别人的主页，返回。",1)
		tool.tap(32,   82,2)
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
	--不关联通讯录，选择第二个吧。
	x,y=tool.findColor({
			{  275,  673, 0xafdefa},
			{  275,  689, 0xafdefa},
			{  294,  686, 0x5fbdf6},
			{  306,  680, 0xb9e2fb},
			{  321,  680, 0x5fbdf6},
			{  306,  804, 0xbce3fb},
			{  331,  807, 0x8fd1f9},
			{  351,  801, 0x6cc2f7},
			},90,{236, 577, 497, 867})
	if x~=-1 and y~=-1 then
		tool.alert("不关联通讯录，选第二个",1)
		tool.tap(370,  803,2)
		return true
	end
	--what are you interested in?
	x,y=tool.findColor({
			{  435,  194, 0x14171a},
			{   37,  180, 0x14171a},
			{   89,  188, 0x14171a},
			{  429,  215, 0x14171a},
			{  365,  189, 0x14171a},
			{  225,  210, 0xffffff},
			{   68,  205, 0xffffff},
			{  138,  199, 0x14171a},
			},90,{22,  170,448,  229})
	if x~=-1 and y~=-1 then
		tool.alert("选择兴趣,跳过",1)
		tool.tap(102, 1295,2)  --左下角是跳过
		tool.alert("5秒后开始寻找关注按钮",5)
		return true
	end
	--左上角Cancelar
	x,y=tool.findColor({
			{   47,   74, 0x288efe},
			{   64,   85, 0x97c7fb},
			{   42,   93, 0x55a5fd},
			{   59,   91, 0x4da1fd},
			{   78,   90, 0x75b6fc},
			{  121,   85, 0x8ec3fb},
			{  134,   85, 0x4ca1fd},
			{  148,   85, 0x79b8fc},
			},90,{3, 17, 196, 780})
	if x>0 then
		tool.alert("左上角Cancelar",1)
		tool.tap(x,y,2)
	end
	--点到图片了
	x,y=tool.findColor({
			{  664, 1174, 0x7c777d},
			{  664, 1183, 0x5c555d},
			{  667, 1188, 0x5c565d},
			{  667, 1183, 0x5c565d},
			{  675, 1179, 0x676168},
			{  682, 1194, 0xb7b4b7},
			{  662, 1199, 0x8a858a},
			{  651, 1187, 0x544d55},
			},90,{602, 1079, 729, 1267})
	if x>0 then
		tool.alert("点到图片了")
		tool.tap(65,   74,2)
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
	--视频需要重新播放
	x,y=tool.findColor({
			{  312,  663, 0xacacac},
			{  317,  660, 0x3c3c3c},
			{  312,  671, 0xacacac},
			{  327,  670, 0x5e5e5e},
			{  329,  664, 0x878787},
			{  325,  671, 0x666666},
			{  342,  671, 0x5f5f5f},
			{  354,  668, 0x6f6f6f},
			},90,{264, 574, 494, 758})
	if x>0 then
		tool.alert("视频播放完了，返回")
		tool.tap(65,   74,2)
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

return task