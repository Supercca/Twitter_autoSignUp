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
				{  342,  578, 0x414142},
				{  347,  578, 0x545454},
				{  347,  588, 0x6d6d6d},
				{  387,  598, 0x666666},
				{  403,  592, 0x787879},
				{  407,  587, 0x303030},
				{  357,  589, 0x787878},
				{  361,  583, 0x464646},
				},90,{130, 562, 622, 698})
		if x>0 then
			tool.alert("哎呀，出错了，重新打开app",2)
			tool.closeApp("com.atebits.Tweetie2")
		end
		--开始界面   识别蓝色字（有小火箭）  Crear una cuenta
		x,y=tool.findColor({
				{  249,  770, 0x51b7f5},
				{  245,  784, 0x9bd5f9},
				{  257,  780, 0x6bc1f7},
				{  278,  776, 0x7ec9f8},
				{  302,  776, 0x98d4f9},
				{  301,  783, 0x5cbbf6},
				{  311,  782, 0x6bc1f7},
				{  342,  784, 0x77c7f7},
				},90,{197, 663, 549, 880})
		if x>0 then
			tool.alert("这是墨西哥版本Twitter,(火箭)现在开始.Crear una cuenta",1)
			tool.tap(x,y,2)
		end
		--开始界面   识别蓝色字  Crear una cuenta
		x,y=tool.findColor({
				{  247,  830, 0x47b2f4},
				{  279,  837, 0x1da1f2},
				{  279,  839, 0x7ec9f8},
				{  297,  845, 0x1da1f2},
				{  301,  842, 0x89cef8},
				{  320,  835, 0x7ec9f8},
				{  342,  847, 0x77c7f7},
				{  384,  845, 0x1da1f2},
				},90,{210, 809, 544, 873})
		if x>0 then
			tool.alert("这是墨西哥版本Twitter,现在开始.Crear una cuenta",1)
			tool.tap(x,y,2)
		end
		--开始界面   识别蓝色字  Conmenzar
		x,y=tool.findColor({
				{  301,  794, 0x20a2f2},
				{  303,  812, 0x9bd5f9},
				{  319,  806, 0x4eb5f5},
				{  328,  806, 0x64bef6},
				{  341,  803, 0x3eaff4},
				{  352,  805, 0x8dcff8},
				{  374,  804, 0x7ec9f8},
				{  400,  801, 0xbae2fb},
				},90,{265, 768, 493, 842})
		if x>0 then
			tool.alert("这是墨西哥版本Twitter,现在开始.Conmenzar",1)
			tool.tap(x,y,2)
		end
		--不关联通讯录，选择第二个
		x,y=tool.findColor({
				{  358,  693, 0x99d5f9},
				{  355,  697, 0x1da1f2},
				{  396,  692, 0x3faff4},
				{  313,  805, 0x43b1f4},
				{  338,  810, 0x8dd0f9},
				{  351,  816, 0x1fa2f2},
				{  372,  810, 0x1da1f2},
				{  427,  815, 0x8fd1f9},
				},90,{182, 648, 573, 831})
		if x>0 then
			tool.alert("不关联通讯录，选择第二个",1)
			tool.tap(362,  813,2)
		end
		--跳过兴趣选择
		x,y=tool.findColor({
				{   38, 1289, 0xb6ddf5},
				{   50, 1296, 0x1b95e0},
				{   65, 1292, 0x1b95e0},
				{   80, 1292, 0x66b8ea},
				{  107, 1298, 0x67b8ea},
				{  123, 1291, 0xa8d7f3},
				{  136, 1286, 0x1b95e0},
				{  153, 1294, 0x1b95e0},
				},90,{21, 1256, 320, 1325})
		if x>0 then
			tool.alert("跳过兴趣选择",1)
			tool.tap(156, 1291,2)
		end
	end
	return same
end

function Sign_Up(info)
	local same=false
	local x,y=-1,-1
	-------------------------------------------------------
	--local info = { userData = {x1 = 'i.ktghwvgin@hotmail.com',x2 = 'OS63SCR82J0S',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--输入Name
	x,y=tool.findColor({
			{  119,  395, 0x657786},
			{  120,  407, 0x778794},
			{  129,  401, 0x657786},
			{  137,  396, 0x657786},
			{  146,  400, 0x97a3ad},
			{  155,  398, 0x667887},
			{  162,  400, 0x657786},
			{  139,  443, 0x657786},
			},90,{67, 370, 243, 452})
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
			{  121,  536, 0x657786},
			{  175,  571, 0x657786},
			{  170,  525, 0x9aa5af},
			{  178,  525, 0x657786},
			{  195,  529, 0x657786},
			{  206,  527, 0x657786},
			{  221,  527, 0xffffff},
			{  243,  533, 0x8e9ba6},
			},90,{66, 495, 417, 585})
	if x>0 then
		tool.alert("切换到输入Mail",1)
		tool.tap(235,  531,1)
	end
	--由电话切换到邮箱
	x,y=tool.findColor({
			{  130,  853, 0x1b95e0},
			{  126,  854, 0x68b9ea},
			{  145,  868, 0x73beec},
			{  147,  859, 0xffffff},
			{  165,  853, 0x1b95e0},
			{  192,  862, 0xa3d4f2},
			{  190,  868, 0x55b0e8},
			{  205,  861, 0x1b95e0},
			},90,{17, 823, 254, 894})
	if x>0 then
		tool.alert("由电话切换到邮箱",1)
		tool.tap(x,y,1)
	end
	--输入邮箱
	x,y=tool.findColor({
			{  241,  534, 0x8795a1},
			{  248,  532, 0x9ba7b1},
			{  248,  525, 0x9ba7b1},
			{  267,  516, 0x657786},
			{  271,  530, 0x657786},
			{  276,  527, 0x9ba7b1},
			{  191,  571, 0x657786},
			{  317,  531, 0x657786},
			},90,{64, 493, 350, 579})
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
			{  163,  341, 0x657786},
			{  161,  355, 0xc5cbd1},
			{  148,  354, 0x657786},
			{  148,  351, 0xffffff},
			{  128,  352, 0x657786},
			{  118,  354, 0x657786},
			{  120,  358, 0x657786},
			{  105,  396, 0xcdd7dd},
			},90,{26, 320, 209, 405})
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
			{  294, 1158, 0xd2ecfc},
			{  297, 1161, 0x1da1f2},
			{  297, 1166, 0x91d1f9},
			{  317, 1163, 0x1da1f2},
			{  340, 1165, 0x9ed6f9},
			{  363, 1160, 0x96d3f9},
			{  378, 1165, 0x84ccf8},
			{  405, 1169, 0x1da1f2},
			},90,{254, 1076, 487, 1255})
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
	--local info = { userData = {x1 = 'i.ktghwvgin@hotmail.com',x2 = 'OS63SCR82J0S',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	x,y=tool.findColor({
			{   64,  448, 0x657786},
			{   62,  450, 0x657786},
			{   68,  463, 0x6f808e},
			{   84,  460, 0x657786},
			{   91,  448, 0x657786},
			{  120,  460, 0xffffff},
			{  140,  461, 0x657786},
			{  159,  461, 0x657786},
			},90,{19, 395, 385, 522})
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
	--local info = { userData = {x1 = 'juliusqkbsvozevyhcs@hotmail.com',x2 = '5XKP2mujf5CL',x3 = 'MICHAEL',x4 = 'ALCORTA',}}
	-------------------------------------------------------
	--这是需要点击Aceptar的界面  识别这个Aceptar
	x,y=tool.findColor({
			{   61,  496, 0x9fd7fa},
			{   67,  491, 0x99d5f9},
			{   69,  497, 0x38acf4},
			{   69,  501, 0x99d5f9},
			{   84,  494, 0x73c5f7},
			{   99,  496, 0x1da1f2},
			{  114,  498, 0x73c5f7},
			{  146,  499, 0x90d1f9},
			},90,{9, 337, 171, 654})
	if x>0 then
		tool.alert("找到Aceptar按钮"..x.." "..y,2)
		tool.tap(x,y,3)
	end
	--页面未加载成功
	x,y=tool.findColor({
			{   53,  329, 0x535353},
			{   47,  329, 0x000000},
			{   55,  331, 0x000000},
			{   59,  328, 0x606060},
			{   75,  329, 0x4b4b4b},
			{   87,  334, 0x898989},
			{   98,  324, 0x757575},
			{  108,  331, 0x7a7a7a},
			},90,{2, 155, 197, 497})
	if x>0 then
		tool.alert("页面未加载完成,点击Aceptar按钮"..x.." "..y,2)
		tool.tap(x,y,3)
	end
	--we sent you a code(三行文字)  识别Next
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
	--Siguiente按钮颜色变深了，再点击一次
	x,y=tool.findColor({
			{   72,  613, 0x81b7df},
			{   70,  622, 0x97c3e5},
			{   93,  620, 0x68a8d9},
			{   93,  609, 0x68a8d9},
			{  101,  623, 0x2b86ca},
			{  112,  616, 0xa6cce9},
			{  121,  625, 0x4b98d2},
			{  150,  619, 0x0e75c2},
			},90,{9, 400, 271, 752})
	if x>0 then
		tool.alert("Siguiente按钮颜色变深了，再点击一次",1)
		tool.tap(x,y,2)
	end
	return same
end

function Follow()
	local same=false
	local x,y=-1,-1
	--关注页面
	x,y=tool.findColor({
			{  377,   88, 0x1da1f2},
			{  361,   82, 0x1da1f2},
			{  420,  199, 0x848687},
			{  397,  203, 0x656769},
			{  396,  200, 0xffffff},
			{  374,  208, 0x909293},
			{  363,  207, 0x14171a},
			{  346,  203, 0x8a8b8d},
			},90,{21, 43, 445, 226})
	if x>0 then
		Point={
			{{{  623,  490, 0x89cef8},{  635,  492, 0x6fc3f7},{  680,  487, 0x93d2f9},{  678,  497, 0xa5dafa},{  674,  498, 0x7cc8f8},{  694,  491, 0x2aa6f3},{  689,  499, 0x98d4f9},{  688,  499, 0x1da1f2}},584, 434, 726, 1245,1,90,"找到关注按钮"},
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
			{  649, 1146, 0xa5d9fa},
			{  662, 1146, 0xa5d9fa},
			{  654, 1142, 0xd2ecfc},
			{  676, 1160, 0x1da1f2},
			{  678, 1153, 0x1da1f2},
			{  366,   70, 0x4e5053},
			{  392,   72, 0x16191c},
			{  397,   73, 0x14171a},
			},90,{290, 34, 721, 1204})
	if x>0 then
		tool.alert("发推按钮在右下角，准备发推文",1)
		tool.tap(672, 1142,2)
	end
	--发推文界面
	x,y=tool.findColor({
			{   44,   71, 0x1da1f2},
			{   67,   93, 0x20a3f3},
			{   69,  180, 0x657786},
			{   63,  211, 0x657786},
			{  436,  175, 0x657786},
			{  440,  180, 0x7b8b98},
			{  435,  197, 0x657786},
			{  272,  174, 0x657786},
			},90,{11, 53, 450, 235})
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
			{  683,   90, 0xdaeffd},
			{  683,   85, 0xdaeffd},
			{  681,   79, 0xfbfdff},
			{  671,   88, 0xbbe2fb},
			{  656,   84, 0xbbe2fb},
			{  638,   84, 0xd4edfd},
			{  627,   82, 0xd4edfd},
			{  601,   90, 0xf9fdff},
			},90,{27, 42, 722, 132})
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
			{  579,   77, 0x45b2f4},
			{  581,   74, 0xc2e5fc},
			{  585,   84, 0xb5e0fb},
			{  597,   86, 0xaadcfa},
			{  606,   84, 0x9fd7fa},
			{  605,   85, 0x4cb4f5},
			{  622,   86, 0x8acef8},
			{  638,   85, 0x70c4f7},
			},90,{551, 45, 718, 122})
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
		tool.alert("这是评论界面",1)
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
	--not allow notification
	x,y=tool.findColor({
			{  218,  707, 0x7ec9f8},
			{  290,  709, 0x74c5f7},
			{  212,  843, 0x6dc2f7},
			{  239,  845, 0x94d2f9},
			{  263,  843, 0x22a3f2},
			{  276,  847, 0x6fc3f7},
			{  494,  847, 0x65bff6},
			{  536,  842, 0x84ccf8},
			},90,{176, 664, 565, 871})
	if x>0 then
		tool.alert("not allow notification，选择第二个",1)
		tool.tap(362,  844,2)
	end
	--Not permitir
	x,y=tool.findColor({
			{  173,  808, 0x3393fc},
			{  189,  804, 0x56a4fa},
			{  191,  819, 0x61aafa},
			{  208,  812, 0xa4ccf7},
			{  211,  821, 0x72b3f9},
			{  235,  809, 0x8bbff8},
			{  250,  810, 0x72b3f9},
			{  271,  810, 0x007aff},
			},90,{147, 784, 334, 835})
	if x>0 then
		tool.alert("Not permitir,选择左边",1)
		tool.tap(247,  809,2)
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
	--发推失败，点击Acepter
	x,y=tool.findColor({
			{  317,  880, 0x54a5fd},
			{  322,  871, 0x7dbafc},
			{  324,  862, 0x6ab0fc},
			{  340,  875, 0x6cb1fc},
			{  347,  867, 0x6bb1fc},
			{  359,  871, 0x007aff},
			{  389,  872, 0x007aff},
			{  411,  874, 0x1c88fe},
			},90,{282, 584, 468, 1057})
	if x>0 then
		tool.alert("点击Acepter",1)
		tool.tap(x,y,2)
	end
	--需要去App store下载软件，点击返回
	x,y=tool.findColor({
			{  307,  501, 0x7f7f7f},
			{  304,  510, 0x5e5e5e},
			{  399,  516, 0x959595},
			{  413,  516, 0x8d8d8d},
			{  424,  510, 0x7e7e7e},
			{  560,  497, 0x007aff},
			{  579,  504, 0x007aff},
			{  581,  478, 0x5ca9fd},
			},90,{6, 419, 746, 569})
	if x>0 then
		tool.alert("需要去App store下载软件，点击返回",1)
		tool.tap(96,  511,2)
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