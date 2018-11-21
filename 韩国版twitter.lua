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
				{  362,  589, 0x585858},
				{  361,  592, 0x939494},
				{  370,  580, 0x646464},
				{  396,  577, 0x363636},
				{  379,  584, 0x7e7e7e},
				{  396,  596, 0x737374},
				{  356,  637, 0x000000},
				{  378,  634, 0x5f5f60},
				},90,{248, 562, 516, 726})
		if x>0 then
			tool.alert("哎呀，出错了，重新打开app",2)
			tool.closeApp("com.atebits.Tweetie2")
		end
		--开始界面   识别蓝色字  시작하기
		x,y=tool.findColor({
				{  339,  816, 0x8fd1f9},
				{  365,  821, 0xb7e1fb},
				{  361,  797, 0x65bff6},
				{  371,  800, 0x84ccf8},
				{  384,  797, 0xb3dffb},
				{  383,  811, 0x1da1f2},
				{  416,  799, 0x45b2f4},
				{  410,  813, 0xd1ecfc},
				},90,{277, 734, 475, 877})
		if x>0 then
			tool.alert("这是韩国版本Twitter,现在开始.시작하기",1)
			tool.tap(x,y,2)
		end
		--开始界面   识别蓝色字  계정생성하기
		x,y=tool.findColor({
				{  281,  731, 0x73c5f7},
				{  294,  736, 0xb4e0fb},
				{  292,  744, 0xacddfa},
				{  301,  749, 0x7ac8f7},
				{  319,  740, 0x4bb4f5},
				{  418,  735, 0xc5e7fc},
				{  399,  750, 0x91d1f9},
				{  367,  747, 0xb1dffb},
				},90,{252, 639, 492, 844})
		if x>0 then
			tool.alert("这是韩国版本Twitter,现在开始.계정생성하기",1)
			tool.tap(x,y,2)
		end

	end
	return same
end

function Sign_Up(info)
	local same
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'philemonntqzsgwznactqz@hotmail.com',x2 = '83UA3yxn54TD',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--输入Name
	x,y=tool.findColor({
			{   80,  396, 0x657786},
			{   91,  396, 0x657786},
			{   98,  395, 0x657786},
			{   97,  408, 0xa7b1ba},
			{  108,  393, 0x657786},
			{  111,  405, 0x919ea9},
			{  123,  407, 0x657786},
			{  123,  388, 0x657786},
			},90,{67, 375, 198, 432})
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
			{  304,  524, 0x657786},
			{  311,  523, 0x657786},
			{  321,  525, 0xa5b0b8},
			{  338,  523, 0x657786},
			{  353,  528, 0xb5bdc5},
			{  347,  534, 0x778794},
			{  402,  525, 0x667887},
			{  406,  534, 0x657786},
			},90,{63, 499, 439, 559})
	if x>0 then
		tool.alert("切换到输入Mail",1)
		tool.tap(235,  531,1)
	end
	--由电话切换到邮箱
	x,y=tool.findColor({
			{  114,  845, 0x1b95e0},
			{  107,  858, 0x1b95e0},
			{  129,  854, 0x1b95e0},
			{  137,  856, 0x1b95e0},
			{  159,  842, 0x52afe7},
			{  169,  849, 0x2198e1},
			{  182,  850, 0x1b95e0},
			{  182,  859, 0xa9d7f3},
			},90,{21, 820, 342, 892})
	if x>0 then
		tool.alert("由电话切换到邮箱",1)
		tool.tap(x,y,1)
	end
	--输入邮箱
	x,y=tool.findColor({
			{   90,  523, 0x83919d},
			{   87,  533, 0x697a89},
			{   98,  529, 0x657786},
			{  106,  526, 0x9ca8b1},
			{  118,  524, 0x657786},
			{  142,  523, 0x6f808e},
			{  149,  522, 0x657786},
			{  145,  534, 0x778794},
			},90,{61, 489, 182, 565})
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
			{   35,  346, 0x657786},
			{   41,  349, 0x919ea9},
			{   54,  349, 0x95a2ac},
			{   60,  345, 0x657786},
			{   75,  354, 0x657786},
			{   78,  345, 0x657786},
			{   95,  349, 0xb1bac2},
			{  104,  347, 0x657786},
			},90,{18, 313, 168, 385})
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
			{  643,  517, 0xe0245e},
			{  649,  518, 0xe0245e},
			{  647,  526, 0xe0245e},
			{  647,  536, 0xe0245e},
			{  645,  549, 0xe0245e},
			{  625,  530, 0xe0245e},
			{  652,  506, 0xe0245e},
			{  668,  526, 0xe0245e},
			},90,{612, 480, 689, 584})
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
			{  369, 1124, 0x95d3f9},
			{  366, 1116, 0x48b3f4},
			{  361, 1106, 0x3caef4},
			{  358, 1102, 0x32aaf3},
			{  374, 1108, 0x66bff6},
			{  379, 1104, 0xb1dffb},
			{  385, 1100, 0x8dd0f9},
			{  388, 1118, 0x7bc8f7},
			},90,{301, 1037, 459, 1192})
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
			{  670,  354, 0x17bf63},
			{  693,  354, 0x17bf63},
			{  686,  357, 0x17bf63},
			{  714,  350, 0x17bf63},
			{  705,  368, 0x17bf63},
			{  680,  369, 0x17bf63},
			{  656, 1264, 0x1da1f2},
			{  681, 1264, 0x1da1f2},
			},90,{585, 294, 738, 1325})
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
	--local info = { userData = {x1 = 'philemonntqzsgwznactqz@hotmail.com',x2 = '83UA3yxn54TD',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	x,y=tool.findColor({
			{  253,  213, 0xffffff},
			{  253,  214, 0x9a9c9d},
			{  253,  217, 0x14171a},
			{  252,  219, 0xffffff},
			{  415,  235, 0xffffff},
			{  415,  236, 0x26282b},
			{  424,  249, 0x212427},
			{  425,  249, 0xffffff},
			{  420,  250, 0x8f9192},
			},90,{194, 188, 464, 265})
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
	--local info = { userData = {x1 = 'philemonntqzsgwznactqz@hotmail.com',x2 = '83UA3yxn54TD',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--这是需要点击확인的界面  识别这个확인
	x,y=tool.findColor({
			{   64,  455, 0x96d3f9},
			{   68,  456, 0x9ed6f9},
			{   66,  459, 0x1da1f2},
			{   78,  464, 0xa6dafa},
			{   91,  454, 0x38acf4},
			{   89,  465, 0x80caf8},
			{  101,  473, 0x97d4f9},
			{  100,  458, 0xd2ecfc},
			},90,{7, 342, 235, 639})
	if x>0 then
		tool.alert("找到확인按钮"..x.." "..y,2)
		tool.tap(x,y,3)
	end
	--we sent you a code(三行文字) 识别다음
	x,y=tool.findColor({
			{   65,  587, 0x69c1f6},
			{   63,  573, 0x80caf8},
			{   80,  580, 0x67bff6},
			{   78,  575, 0x67bff6},
			{   78,  588, 0x67bff6},
			{   93,  585, 0x7ec9f8},
			{   92,  574, 0x85ccf8},
			{   94,  593, 0xaeddfa},
			},90,{4, 321, 314, 786})
	if x>0 then
		tool.alert("找到다음按钮"..x.." "..y,2)
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
			tool.tap(x,y,5)  --点击다음按钮
		end
	end
	return same
end

function Follow()
	local same=false
	local x,y=-1,-1
	--关注页面
	x,y=tool.findColor({
			{   36,  188, 0x14171a},
			{   38,  186, 0x404345},
			{  166,  203, 0xffffff},
			{  208,  195, 0x47494b},
			{  287,  193, 0x14171a},
			{  346,  186, 0x424547},
			{  345,  212, 0x14171a},
			{  396,  197, 0x14171a},
			},90,{23, 160, 413, 243})
	if x~=-1 and y~=-1 then
		Point = {
			{{{  683,  496, 0x7ec9f8},{  675,  497, 0x1da1f2},{  691,  497, 0x1da1f2},{  681,  487, 0xffffff},{  684,  487, 0xffffff},{  684,  504, 0x8ed0f9},{  685,  485, 0x4fb6f5},{  684,  505, 0x8ed0f9}},596, 434, 725, 1244,1,90,"关注"},
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
				tool.sleep(2)
				tool.tap(606, 1294)		--点击右下角关注按钮，进入主页
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
	--Twitter主页 发推按钮在右下角
	x,y=tool.findColor({
			{  371,   71, 0x656769},
			{  379,   75, 0x494c4e},
			{  376,   85, 0x636567},
			{  368,   94, 0x898a8c},
			{  376,   95, 0xb7b8b9},
			{  366,   98, 0x858788},
			{  383,   82, 0x8b8c8e},
			{  386,   73, 0x5d5f61},
			},90,{290, 34, 721, 1204})
	if x>0 then
		tool.alert("发推按钮在右下角，准备发推文",1)
		tool.tap(672, 1142,2)
	end
	--发推文界面
	x,y=tool.findColor({
			{  664,   92, 0xd5edfd},
			{  647,   81, 0xe4f4fd},
			{  656,   75, 0xdaeffd},
			{  673,   78, 0xceeafc},
			{  675,   91, 0xd8effd},
			{  686,   86, 0xdbf0fd},
			{  686,   77, 0xdbf0fd},
			{  674,   77, 0xbbe2fb},
			},90,{28, 42, 723, 132})
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
			{  657,   75, 0x85ccf8},
			{  649,   78, 0x91d1f9},
			{  649,   90, 0x55b8f5},
			{  656,   90, 0x55b8f5},
			{  670,   76, 0xb4e0fb},
			{  675,   82, 0xa5d9fa},
			{  686,   83, 0x88cef8},
			{  683,   92, 0x7ec9f8},
			},90,{590, 37, 734, 131})
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
			{   54,   83, 0x1da1f2},
			{   67,   72, 0x1da1f2},
			{  645,   77, 0xe1f3fd},
			{  650,   92, 0xbbe2fb},
			{  656,   88, 0xd4edfd},
			{  678,   74, 0xdff2fd},
			{  678,   82, 0xdef1fd},
			{  672,   92, 0xbbe2fb},
			},90,{27, 38, 741, 126})
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
			{  645,   75, 0xa9dbfa},
			{  647,   81, 0xadddfa},
			{  653,   88, 0x72c4f7},
			{  653,   91, 0x1da1f2},
			{  655,   93, 0x7cc8f7},
			{  678,   82, 0x93d2f9},
			{  671,   74, 0x97d4f9},
			{  673,   89, 0xb6e1fb},
			},90,{599, 39, 733, 122})
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
	--不允许关联通讯录
	x,y=tool.findColor({
			{  261,  690, 0x1da1f2},
			{  287,  688, 0x1da1f2},
			{  332,  806, 0x1da1f2},
			{  346,  815, 0x6ec2f7},
			{  377,  803, 0x1da1f2},
			{  399,  810, 0xffffff},
			{  405,  809, 0x1da1f2},
			{  415,  811, 0x1da1f2},
			},90,{241, 632, 523, 839})
	if x~=-1 and y~=-1 then
		tool.alert("选择第二个",1)
		tool.tap(374,  813,2)
	end
	--what are you interested in?
	x,y=tool.findColor({
			{   39,  190, 0x14171a},
			{  528,  214, 0x14171a},
			{  536,  196, 0x14171a},
			{  492,  200, 0x14171a},
			{  249,  187, 0xffffff},
			{  297,  193, 0x303235},
			{  344,  191, 0x8a8b8d},
			{  344,  199, 0x4e5053},
			},90,{23, 160, 563, 236})
	if x~=-1 and y~=-1 then
		tool.alert("选择兴趣,跳过",1)
		tool.tap(166, 1293,3)
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
		tool.alert("个性化定制",2)
		tool.tap(655, 1290,2)
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
	--重复推文
	x,y=tool.findColor({
			{  262,  605, 0x6f7070},
			{  319,  612, 0x6f6f6f},
			{  319,  595, 0x767676},
			{  322,  590, 0xafafaf},
			{  356,  594, 0x6b6b6b},
			{  361,  607, 0x989898},
			{  388,  643, 0x868787},
			{  407,  646, 0x6e6f6f},
			},90,{213, 569, 536, 676})
	if x>0 then
		tool.alert("未知错误，重新打开APP",2)
		tool.closeApp("com.atebits.Tweetie2")
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