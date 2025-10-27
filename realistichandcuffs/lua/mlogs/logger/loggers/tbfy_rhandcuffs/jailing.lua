--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "rhandcuff"

mLogs.addLogger("Jailing","jailing",category)
mLogs.addHook("RHC_jailed", category, function(vic, jailer, time, reason)
	if(not IsValid(vic) or not IsValid(jailer))then return end
	mLogs.log("jailing", category, {player1=mLogs.logger.getPlayerData(jailer),player2=mLogs.logger.getPlayerData(vic),time=time, reason=reason,a=true})
end)