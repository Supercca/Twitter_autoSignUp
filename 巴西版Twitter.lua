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
		--出错了，关闭app
		x,y=tool.findColor({
				{  353,  595, 0x5d5d5d},
				{  349,  588, 0x6c6c6c},
				{  356,  578, 0x535353},
				{  367,  582, 0x7b7c7c},
				{  377,  592, 0x777777},
				{  402,  590, 0xb7b7b8},
				{  389,  589, 0x9b9b9b},
				{  416,  665, 0x8e8f90},
				},90,{187, 561, 564, 697})
		if x>0 then
			tool.alert("哎呀，出错了，重新打开app",2)
			tool.closeApp("com.atebits.Tweetie2")
		end
		--出错了，关闭app
		x,y=tool.findColor({
				{  367,  592, 0x585959},
				{  400,  595, 0x575757},
				{  348,  623, 0x020202},
				{  317,  631, 0x6b6b6b},
				{  351,  629, 0x000000},
				{  370,  632, 0x313131},
				{  388,  632, 0x8d8d8d},
				{  397,  624, 0x000000},
				},90,{245, 552, 509, 700})
		if x>0 then
			tool.alert("哎呀，出错了，重新打开app",2)
			tool.closeApp("com.atebits.Tweetie2")
		end
		--开始界面   识别蓝色字（有小火箭） Criar conta
		x,y=tool.findColor({
				{  296,  766, 0x4fb6f5},
				{  291,  766, 0xd0ebfc},
				{  341,  779, 0x89cef8},
				{  351,  779, 0x6bc1f7},
				{  378,  777, 0x4eb5f5},
				{  407,  779, 0x7ac8f7},
				{  415,  781, 0x6bc1f7},
				{  442,  772, 0x9ed7f9},
				},90,{251, 667, 491, 892})
		if x>0 then
			tool.alert("这是巴西版本Twitter,(火箭)Criar conta",1)
			tool.tap(x,y,2)
		end
		--开始界面   识别蓝色字 Introducao
		x,y=tool.findColor({
				{  287,  790, 0x6fc3f7},
				{  294,  807, 0x6bc1f7},
				{  305,  800, 0xc5e7fc},
				{  316,  800, 0x61bdf6},
				{  321,  809, 0x75c5f7},
				{  339,  800, 0x7bc8f7},
				{  351,  806, 0x1da1f2},
				{  377,  806, 0x50b6f5},
				},90,{254, 714, 478, 904})
		if x>0 then
			tool.alert("这是巴西版本Twitter,Introducao",1)
			tool.tap(x,y,2)
		end


	end
	return same	
end

function Sign_Up(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'marylezznmupcdndlk@hotmail.com',x2 = '7Ba2b8av5h6e',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--输入Name
	x,y=tool.findColor({
			{  150,  402, 0x7d8c99},
			{  137,  402, 0x99a5af},
			{  130,  398, 0x9ba7b0},
			{  120,  394, 0xa2acb5},
			{  110,  406, 0xcbd1d6},
			{  102,  402, 0x8f9ca7},
			{   96,  395, 0xa9b3bb},
			{   81,  394, 0x657786},
			},90,{64, 363, 237, 455})
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
			{  231,  530, 0x7d8c99},
			{  247,  528, 0x93a0aa},
			{  263,  524, 0xb0b9c1},
			{  267,  530, 0x7a8a97},
			{  277,  530, 0xc7cdd3},
			{  290,  530, 0x8895a1},
			{  304,  524, 0xb2bbc3},
			{  304,  534, 0xb2bbc3},
			},90,{132, 468, 346, 577})
	if x>0 then
		tool.alert("切换到输入Mail",1)
		tool.tap(235,  531,1)
	end
	--由电话切换到邮箱
	x,y=tool.findColor({
			{  152,  862, 0xa3d4f2},
			{  160,  856, 0x70bdec},
			{  174,  862, 0xcbe7f8},
			{  176,  860, 0x1b95e0},
			{  192,  854, 0x8fcbf0},
			{  199,  865, 0xcbe7f8},
			{  207,  865, 0xa6d6f3},
			{  224,  862, 0xadd9f4},
			},90,{129, 796, 279, 918})
	if x>0 then
		tool.alert("由电话切换到邮箱",1)
		tool.tap(x,y,1)
	end
	--输入邮箱
	x,y=tool.findColor({
			{   87,  528, 0xc7cdd3},
			{   96,  530, 0xafb9c0},
			{  102,  528, 0x93a0aa},
			{  110,  534, 0x9ba7b1},
			{  122,  531, 0xc8ced3},
			{  129,  528, 0x99a5af},
			{  143,  530, 0x8795a1},
			{  154,  529, 0xbbc3ca},
			},90,{57, 481, 212, 576})
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
			{   47,  345, 0x657786},
			{   46,  354, 0x657786},
			{   60,  354, 0x657786},
			{   88,  350, 0x657786},
			{   98,  359, 0x657786},
			{  114,  354, 0x657786},
			{   87,  342, 0x657786},
			{   70,  357, 0x657786},
			},90,{15,  307,133,  396})
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
			{  284, 1133, 0x99d5f9},
			{  294, 1140, 0xa4d9fa},
			{  299, 1138, 0x70c4f7},
			{  313, 1143, 0x66bff6},
			{  330, 1148, 0x2ba7f3},
			{  348, 1149, 0xc4e6fc},
			{  364, 1143, 0x1da1f2},
			{  381, 1151, 0x69c1f6},
			},90,{258, 1074, 491, 1209})
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
			{  684,  354, 0x17bf63},
			{  689,  358, 0x17bf63},
			{  700,  344, 0x17bf63},
			{  597, 1286, 0x1fa2f2},
			{  613, 1294, 0x1da1f2},
			{  628, 1294, 0x1da1f2},
			{  644, 1288, 0x1da1f2},
			{  662, 1304, 0x83cbf8},
			},90,{548, 314, 730, 1320})
	if x>0 then
		tool.alert("确认密码按钮到下面去了",1)
		tool.tap(637, 1286,5)
	end
	return same
end

function VerityMail_new(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'marylezznmupcdndlk@hotmail.com',x2 = '7Ba2b8av5h6e',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	x,y=tool.findColor({
			{  380,   77, 0x1da1f2},
			{  361,   90, 0x1da1f2},
			{   37,  219, 0x14171a},
			{  115,  215, 0x14171a},
			{  371,  215, 0x14171a},
			{  420,  217, 0x14171a},
			{  694,  218, 0x14171a},
			{  683,  218, 0x14171a},
			},90,{19, 56, 720, 254})
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

function VerityMail_old(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'marylezznmupcdndlk@hotmail.com',x2 = '7Ba2b8av5h6e',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--这是需要点击OK的界面  识别这个OK
	x,y=tool.findColor({
			{   59,  463, 0x71c4f7},
			{   63,  459, 0x95d3f9},
			{   69,  453, 0x6fc3f7},
			{   69,  466, 0x6ec2f7},
			{   81,  464, 0x9ed6f9},
			{   92,  459, 0x82cbf8},
			{   81,  451, 0x9ed6f9},
			{   81,  469, 0x9ed6f9},
			},90,{9, 337, 171, 654})
	if x>0 then
		tool.alert("找到OK按钮"..x.." "..y,2)
		tool.tap(x,y,3)
	end
	--we sent you a code(三行文字) 全英文 识别Next
	x,y=tool.findColor({
			{   68,  579, 0x1da1f2},
			{   80,  579, 0x88cef8},
			{   95,  579, 0xcceafc},
			{   99,  587, 0x8fd1f9},
			{  109,  586, 0x88cef8},
			{  114,  593, 0x68c0f6},
			{  163,  589, 0x8dd0f9},
			{  157,  584, 0x7ec9f8},
			},90,{6, 415, 276, 743})
	if x>0 then
		tool.alert("找到Proximo按钮"..x.." "..y,2)
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
			tool.tap(x,y,5)  --点击Proximo按钮
		end
	end
	--we sent you a code(三行文字) 全墨西哥文 识别Siguiente
	x,y=tool.findColor({
			{   91,  621, 0x1da1f2},
			{   79,  615, 0x88cef8},
			{   66,  617, 0x9cd6f9},
			{  111,  622, 0x74c5f7},
			{  118,  619, 0x72c4f7},
			{  118,  625, 0x72c4f7},
			{  131,  621, 0xd0ebfc},
			{  145,  622, 0x8dd0f9},
			},90,{4, 321, 314, 786})
	if x>0 then
		tool.alert("找到Siguiente按钮"..x.." "..y,2)
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
			tool.tap(x,y,5)  --点击Siguiente按钮
		end
	end
	return same
end

function Follow()
	local same=false
	local x,y=-1,-1
	--关注页面
	x,y=tool.findColor({
			{   53,  190, 0x14171a},
			{  194,  186, 0x14171a},
			{   43,  383, 0x14171a},
			{  229,  377, 0x14171a},
			{  309,  387, 0x14171a},
			{  362,  378, 0x14171a},
			{  434,  270, 0xffffff},
			{  107,  303, 0xffffff},
			},90,{22,  174,663,  428})
	if x~=-1 and y~=-1 then
		Point = {
			{{{  622,  733, 0x1da1f2},{  612,  737, 0x1da1f2},{  617,  748, 0x99d5f9},{  634,  740, 0xffffff},{  655,  741, 0x1da1f2},{  663,  740, 0x1da1f2},{  673,  738, 0x1da1f2},{  680,  731, 0x1da1f2}},568,  436,739, 1241,1,90,"找到关注按钮"},
		}
		local x,y=-1,-1
		for i,v in ipairs(Point) do
			x,y=tool.findColor(v[1], v[7], {v[2], v[3], v[4], v[5]})
			if x>0 then
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
			{  334,   74, 0x14171a},
			{  336,   89, 0x14171a},
			{  367,   70, 0x14171a},
			{  395,   71, 0x14171a},
			{  679,   74, 0x1da1f2},
			{  712,   67, 0x1da1f2},
			{  695,   79, 0x1da1f2},
			{  689,   88, 0x1da1f2},
			},90,{311,   46,725,  117})
	if x>0 then
		tool.alert("发推按钮在右上角，准备发推文")
		tool.tap(697,   82,2)
	end
	--Twitter主页 发推按钮在右下角  单独识别右下角发推按钮
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
			{  679,   88, 0xd8effd},
			{  671,   87, 0xd3ecfd},
			{  657,   85, 0xdef1fd},
			{  640,   89, 0xc8e8fc},
			{  641,   83, 0xbbe2fb},
			{  627,   83, 0xbbe2fb},
			{  623,   89, 0xeaf6fe},
			{  610,   83, 0xeff8fe},
			},90,{26, 39, 736, 130})
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
			{  688,   80, 0x80caf8},
			{  679,   83, 0x7fcaf8},
			{  670,   85, 0xd7eefd},
			{  668,   89, 0x1da1f2},
			{  657,   84, 0x93d2f9},
			{  644,   81, 0xadddfa},
			{  644,   84, 0x1da1f2},
			{  626,   81, 0x88cef8},
			},90,{551, 45, 718, 122})
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
			{  550,   77, 0xc3e6fc},
			{  556,   80, 0xbbe2fb},
			{  546,   92, 0xe2f3fd},
			{  571,   83, 0xbbe2fb},
			{  602,   90, 0xbbe2fb},
			{  622,   85, 0xbbe2fb},
			{  629,   84, 0xd8effd},
			{  669,   84, 0xbbe2fb},
			},90,{516, 44, 716, 126})
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
			{  546,   78, 0xa0d8fa},
			{  554,   81, 0x1da1f2},
			{  556,   91, 0x9fd7fa},
			{  570,   83, 0x1da1f2},
			{  587,   85, 0xa8dbfa},
			{  605,   83, 0x67c0f6},
			{  621,   82, 0x55b8f5},
			{  651,   85, 0x1da1f2},
			},90,{511, 44, 719, 126})
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
	--无视输入密码
	x,y=tool.findColor({
			{   42,   74, 0x78c7f7},
			{   51,   79, 0x87cdf8},
			{   51,   84, 0x87cdf8},
			{   40,   86, 0x90d1f9},
			{   91,   82, 0x95d3f9},
			{  112,   79, 0xb0defa},
			{  105,   95, 0x75c5f7},
			{  140,   90, 0x96d3f9},
			},90,{11, 42, 173, 128})
	if x>0 then
		tool.alert("无视输入密码",1)
		tool.tap(x,y,2)
	end
	--不关联通讯录，选择第二个
	x,y=tool.findColor({
			{  452,  540, 0x14171a},
			{  359,  513, 0x14171a},
			{  361,  531, 0x14171a},
			{  374,  519, 0x14171a},
			{  390,  518, 0x14171a},
			{  303,  516, 0x14171a},
			{  307,  479, 0x14171a},
			{  360,  476, 0x14171a},
			},90,{228,  453,569,  555})
	if x>0 then
		tool.alert("不关联通讯录，选择第二个",2)
		tool.tap(380,  811,2)
	end
	x,y=tool.findColor({
			{   38,  191, 0x14171a},
			{   77,  204, 0xffffff},
			{  286,  185, 0x14171a},
			{  407,  186, 0x14171a},
			{  627,  191, 0x14171a},
			{  619,  214, 0x14171a},
			{  474,  200, 0xffffff},
			{  281,  214, 0x14171a},
			},90,{21,  157,643,  241})
	if x>0 then
		tool.alert("选择兴趣,跳过",2)
		tool.tap(166, 1293,2)
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
	if x>0 then
		tool.alert("个性化定制",2)
		tool.tap(655, 1290,2)
	end
	--系统弹窗（是否允许twitter通知）
	x,y=tool.findColor({
			{  246,  536, 0x000000},
			{  581,  643, 0x454848},
			{  458,  612, 0x000000},
			{  480,  583, 0x000000},
			{  494,  711, 0x141818},
			{  452,  791, 0x007aff},
			{  451,  812, 0x007aff},
			{  556,  790, 0x007aff},
			},90,{103,  486,646,  846})
	if x>0 then
		tool.alert("是否允许twitter通知",2)
		tool.tap(258,  801,2)  --左边不允许
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