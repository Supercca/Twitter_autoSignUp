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
		--开始界面   识别蓝色字  Create account
		x,y=tool.findColor({
				{  261,  794, 0xa6dafa},
				{  294,  804, 0x7ec9f8},
				{  294,  801, 0x1da1f2},
				{  315,  804, 0x69c1f6},
				{  317,  810, 0x9bd5f9},
				{  332,  804, 0x74c5f7},
				{  347,  804, 0x7ec9f8},
				{  350,  812, 0xaeddfa},
				},90,{218, 714, 525, 895})
		if x>0 then
			tool.alert("这是美国/菲律宾版本Twitter,Create account",1)
			tool.tap(x,y,2)
		end
		--开始界面   识别蓝色字  Create account
		x,y=tool.findColor({
				{  296,  802, 0x5fbcf6},
				{  314,  804, 0x7ec9f8},
				{  333,  809, 0x75c5f7},
				{  349,  800, 0x73c5f7},
				{  374,  810, 0x9fd7fa},
				{  393,  804, 0x98d4f9},
				{  422,  804, 0x74c5f7},
				{  439,  804, 0x7ec9f8},
				},90,{234, 712, 525, 911})
		if x>0 then
			tool.alert("这是美国/菲律宾版本Twitter,Get Started",1)
			tool.tap(x,y,2)
		end
	end
	return same
end

function Sign_Up(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'gardinerjyshblxmhymjl@hotmail.com',x2 = '7FkRwKi9JkzM',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--输入Name
	x,y=tool.findColor({
			{   84,  396, 0xb8c1c7},
			{   96,  408, 0xa9b3bb},
			{   96,  392, 0xa9b3bb},
			{  110,  402, 0x70818f},
			{  112,  407, 0x8b98a3},
			{  119,  397, 0x657786},
			{  128,  401, 0x7a8a97},
			{  148,  402, 0x7d8c99},
			},90,{66, 365, 190, 449})
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
			{  291,  535, 0x97a3ad},
			{  304,  534, 0x9ba7b1},
			{  312,  523, 0x9da8b2},
			{  329,  530, 0x7d8c99},
			{  340,  531, 0x9ba7b1},
			{  352,  529, 0xc8ced3},
			{  370,  529, 0x657786},
			{  391,  526, 0xaeb7bf},
			},90,{173, 484, 454, 584})
	if x>0 then
		tool.alert("切换到输入Mail",1)
		tool.tap(235,  531,1)
	end
	--由电话切换到邮箱
	x,y=tool.findColor({
			{  114,  862, 0xa3d4f2},
			{  118,  856, 0x70bdec},
			{  131,  855, 0x7dc3ed},
			{  141,  862, 0xcbe7f8},
			{  152,  866, 0x6ebceb},
			{  164,  862, 0x8ecbf0},
			{  179,  861, 0x2c9de2},
			{  179,  845, 0x1b95e0},
			},90,{94, 798, 204, 914})
	if x>0 then
		tool.alert("由电话切换到邮箱",1)
		tool.tap(x,y,1)
	end
	--输入邮箱
	x,y=tool.findColor({
			{  139,  518, 0x768693},
			{  138,  525, 0xa5afb8},
			{  138,  535, 0xa5afb8},
			{  145,  534, 0xb2bbc3},
			{  145,  518, 0xb2bbc3},
			{  115,  532, 0x99a5af},
			{  108,  529, 0xc8ced3},
			{   98,  531, 0x778794},
			},90,{54, 485, 184, 583})
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
			{   36,  344, 0x657786},
			{   62,  357, 0x657786},
			{   92,  356, 0x657786},
			{  107,  349, 0x657786},
			{  126,  352, 0xffffff},
			{  138,  352, 0x657786},
			{  150,  350, 0x6a7b8a},
			{  160,  350, 0x657786},
			},90,{23,  329,188,  377})
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
			{  334, 1121, 0x84ccf8},
			{  324, 1133, 0x7ec9f8},
			{  344, 1125, 0xcbe9fc},
			{  344, 1117, 0x74c5f7},
			{  355, 1128, 0x1da1f2},
			{  379, 1131, 0x99d5f9},
			{  406, 1129, 0xaeddfa},
			{  418, 1128, 0x5fbcf6},
			},90,{283, 1058, 454, 1204})
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
	--确认密码的按钮下去了
	x,y=tool.findColor({
			{  684,  354, 0x17bf63},
			{  689,  358, 0x17bf63},
			{  697,  346, 0x17bf63},
			{  713,  350, 0x17bf63},
			{  636, 1269, 0x1da1f2},
			{  662, 1268, 0x1da1f2},
			{  682, 1272, 0x1da1f2},
			{  653, 1262, 0x1da1f2},
			},90,{552, 293, 730, 1325})
	if x>0 then
		tool.alert("确认密码的按钮下去了",1)
		tool.tap(668, 1292,5)
	end
	return same
end

function VerityMail_new(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'gardinerjyshblxmhymjl@hotmail.com',x2 = '7FkRwKi9JkzM',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	x,y=tool.findColor({
			{   41,  219, 0x5a5c5e},
			{   45,  236, 0x6a6c6e},
			{   54,  229, 0x57595c},
			{   62,  236, 0x56585b},
			{   70,  219, 0x14171a},
			{   87,  232, 0x656769},
			{  125,  235, 0x14171a},
			{  183,  235, 0x14171a},
			},90,{18, 194, 456, 266})
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
	--local info = { userData = {x1 = 'gardinerjyshblxmhymjl@hotmail.com',x2 = '7FkRwKi9JkzM',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
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
			{   64,  581, 0x76c6f7},
			{   71,  592, 0x91d1f9},
			{   72,  586, 0x7bc8f7},
			{   72,  578, 0x60bdf6},
			{   79,  587, 0x9dd6f9},
			{   85,  585, 0xd0ebfc},
			{   84,  590, 0x71c4f7},
			{   85,  583, 0x1da1f2},
			},90,{4, 321, 314, 786})
	if x>0 then
		tool.alert("找到Next按钮"..x.." "..y,2)
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
			tool.tap(x,y,5)  --点击Next按钮
		end
	end
	--深颜色的Next
	x,y=tool.findColor({
			{   57,  609, 0x006dbf},
			{   68,  619, 0xcae1f2},
			{   73,  615, 0x83b8e0},
			{   82,  618, 0x2e87ca},
			{   99,  618, 0x006dbf},
			{   96,  625, 0x4695d1},
			{  113,  621, 0x3e90cf},
			{  128,  621, 0x8dbee2},
			},90,{4, 419, 256, 798})
	if x>0 then
		tool.alert("Next已按下，但无反应，再点击一下。")
		tool.tap(x,y,2)
	end
	return same
end

function Follow()
	local same=false
	local x,y=-1,-1
	--关注页面
	x,y=tool.findColor({
			{  414,  194, 0xaaabac},
			{  492,  212, 0x494c4e},
			{  545,  200, 0x9a9b9c},
			{  562,  212, 0x6c6e70},
			{  587,  208, 0x67696b},
			{  600,  209, 0x67696b},
			{  613,  200, 0x797b7d},
			{  644,  197, 0x535557},
			},90, {410, 190, 645, 215})
	if x~=-1 and y~=-1 then
		Point = {
			{{{  595,  647, 0x1da1f2},{  604,  638, 0x1ea1f2},{  614,  657, 0x1da1f2},{  634,  660, 0x1da1f2},{  646,  657, 0x1da1f2},{  654,  659, 0x7fcaf8},{  652,  633, 0x24a4f3},{  690,  633, 0xb7e1fb}},525, 365, 730, 1259,1,90},
		}
		local x, y, z = -1, -1
		for i, v in ipairs(Point) do
			x, y = tool.findColor(v[1], v[7], {v[2], v[3], v[4], v[5]})
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
	--Twitter主页 发推按钮在右上角
	x,y=tool.findColor({
			{  717,   66, 0x58baf6},
			{  707,   78, 0x8cd0f9},
			{  706,   82, 0x54b8f6},
			{  682,  103, 0x4cb5f5},
			{  692,  128, 0xbbc6ce},
			{  681,   84, 0xb2dffb},
			{  679,   75, 0x1da1f2},
			{  675,   74, 0x78c7f8},
			},90,{661, 49, 730, 136})
	if x>0 then
		tool.alert("发推按钮在右上角，准备发推文",1)
		tool.tap(697,   82,2)
	end
	--Twitter主页 发推按钮在右下角
	x,y=tool.findColor({
			{  333,   72, 0x35383a},
			{  338,   81, 0x7b7d7f},
			{  343,   86, 0x595b5d},
			{  352,   86, 0x757678},
			{  362,   81, 0x4f5153},
			{  650, 1146, 0xa5d9fa},
			{  661, 1146, 0xa5d9fa},
			{  682, 1154, 0xc8e8fc},
			},90,{290, 34, 721, 1204})
	if x>0 then
		tool.alert("发推按钮在右下角，准备发推文",1)
		tool.tap(672, 1142,2)
	end
	--发推文界面
	x,y=tool.findColor({
			{  417,  198, 0x657786},
			{  424,  180, 0xbcc4ca},
			{  210,  176, 0xa9b3bb},
			{  214,  195, 0x7e8d9a},
			{  619,   77, 0xcbe9fc},
			{  631,   89, 0xd6eefd},
			{  640,   89, 0xd6eefd},
			{  654,   85, 0xf7fcff},
			},90,{100, 35, 725, 249})
	if x>0 then
		tool.alert("这是发推文界面",1)
		local rs = ""
		for i=1,8,1 do
			rs = rs..string.char(math.random(97,122))
		end
		tool.pasteText("Hi~welecome to twitter."..rs)
	end
	--发推文界面
	x,y=tool.findColor({
			{   44,   73, 0x1da1f2},
			{   64,   91, 0x1da1f2},
			{  615,   79, 0xe9f6fe},
			{  620,   77, 0xcbe9fc},
			{  631,   89, 0xd6eefd},
			{  635,   84, 0xdbf0fd},
			{  640,   89, 0xd6eefd},
			{  655,   83, 0xbbe2fb},
			},90,{19, 39, 738, 126})
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
			{  611,   74, 0xc2e5fc},
			{  615,   85, 0xb5e0fb},
			{  631,   89, 0x76c6f7},
			{  640,   89, 0x76c6f7},
			{  654,   81, 0x88cef8},
			{  671,   87, 0x70c4f7},
			{  685,   88, 0x93d2f9},
			{  672,   83, 0x1da1f2},
			},90,{571, 42, 724, 126})
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
			{   43,   72, 0x1da1f2},
			{   67,   93, 0x20a3f3},
			{   42,   95, 0x20a3f3},
			{   68,   71, 0x1da1f2},
			{  621,   77, 0xc3e6fc},
			{  615,   92, 0xbbe2fb},
			{  667,   88, 0xd1ecfc},
			{  681,   89, 0xd3edfd},
			},90,{26, 45, 725, 125})
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
			{  619,   74, 0xc2e5fc},
			{  616,   89, 0xa0d8fa},
			{  621,   86, 0x9fd7fa},
			{  640,   85, 0xe6f5fe},
			{  642,   91, 0xd8effd},
			{  653,   86, 0x7ec9f8},
			{  660,   85, 0x51b7f5},
			{  681,   90, 0xbde3fb},
			},90,{571, 41, 726, 126})
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
	--Dont;t Allow
	x,y=tool.findColor({
			{  227,  763, 0xbfc3c7},
			{  162,  763, 0xc7c7cb},
			{  158,  806, 0x007aff},
			{  163,  817, 0x4ca0fc},
			{  191,  810, 0x3e99fc},
			{  201,  810, 0x72b3f9},
			{  221,  799, 0x65acfa},
			{  228,  801, 0x007aff},
			},90,{130, 741, 349, 843})
	if x>0 then
		tool.alert("Dont't allow",1)
		tool.tap( 238,  810,2)
	end
	--不允许通知
	x,y=tool.findColor({
			{  311,  585, 0x000000},
			{  324,  602, 0x4f5051},
			{  346,  593, 0x828485},
			{  366,  599, 0x87898b},
			{  447,  581, 0x000000},
			{  220,  791, 0x007aff},
			{  251,  801, 0x007aff},
			{  271,  803, 0x007aff},
			},90,{137, 521, 620, 833})
	if x>0 then
		tool.alert("Don't allow")
		tool.tap(238,  802,2)
	end
	--出错了，重新打开app
	x,y=tool.findColor({
			{  349,  578, 0x545454},
			{  340,  576, 0x000000},
			{  345,  588, 0x6c6d6d},
			{  346,  597, 0x000000},
			{  361,  588, 0x555555},
			{  371,  587, 0x000000},
			{  356,  764, 0x007aff},
			{  386,  764, 0x007aff},
			},90,{129, 543, 623, 789})
	if x>0 then
		tool.alert("出错了，重新打开app",1)
		tool.closeApp("com.atebits.Tweetie2")
	end
	--不上传头像
	x,y=tool.findColor({
			{  134,  393, 0x58baf5},
			{  142,  633, 0xf0f1f3},
			{  147,  550, 0xa8d6f3},
			{  177,  487, 0x91cdf3},
			{  179,  502, 0x7ac5f3},
			{  208,  492, 0x24a4f2},
			{  230,  550, 0x3daef2},
			{  251,  667, 0x1da1f2},
			},90, {130, 390, 255, 670})
	if x~=-1 and y~=-1 then
		tool.alert("不上传头像")
		tool.tap(668, 1292)
	end
	--不关联通讯录，选择第二个
	x,y=tool.findColor({
			{  308,  788, 0xb5e0fb},
			{  323,  803, 0xffffff},
			{  360,  805, 0xa8dbfa},
			{  376,  796, 0xb1dffb},
			{  387,  794, 0x8fd1f9},
			{  397,  808, 0x6ac1f6},
			{  402,  799, 0x6cc2f7},
			{  435,  805, 0x72c4f7},
			},90, {305, 785, 440, 810})
	if x~=-1 and y~=-1 then
		tool.alert("暂时不关联通讯录",2)
		tool.tap(x,y,2)
	end
	x,y=tool.findColor({
			{  332,  191, 0x313336},
			{  351,  200, 0x888a8b},
			{  401,  203, 0x656769},
			{  424,  200, 0x838587},
			{  492,  210, 0x696b6d},
			{  516,  207, 0x585a5c},
			{  570,  189, 0x14171a},
			{  613,  214, 0x14171a},
			},90, {330, 185, 615, 215})
	if x~=-1 and y~=-1 then
		tool.alert("对什么都不感兴趣,跳过")
		tool.sleep(2)
		tool.tap(117, 1290)
		tool.sleep(3)
		tool.alert("5秒后开始寻找关注按钮")
		tool.sleep(5)
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
	--识别到watch again 退出
	x,y=tool.findColor({
			{  297,  659, 0x6d6d6e},
			{  300,  671, 0x89898a},
			{  305,  664, 0x606061},
			{  311,  670, 0x1f1f20},
			{  324,  672, 0x0e0d0f},
			{  327,  665, 0x4e4e4f},
			{  336,  671, 0x676667},
			{  365,  671, 0x9d9d9d},
			},90,{279, 628, 471, 710})
	if x>0 then
		tool.alert("识别到watch again 退出",1)
		tool.tap(65,   76,2)
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
			tool.dlg("当前获取数据10次失败，不获取了", 5)
			return ""
		end
	end
end

return task